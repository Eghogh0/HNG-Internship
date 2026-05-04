import { Router, Response } from 'express';
import { authenticate, AuthRequest } from '../middleware/authenticate';
import { authorize } from '../middleware/authorize';
import { apiVersion } from '../middleware/apiVersion';
import { apiLimiter } from '../middleware/rateLimiter';
import * as profileModel from '../models/profile';
import { parseNaturalQuery } from '../services/naturalLanguage';
import { enrichProfile } from '../services/profileEnrichment';
import { AppError } from '../utils/errors';

const router = Router();

// Apply authentication and API version to all profile routes
router.use(authenticate, apiVersion, apiLimiter);

// GET /api/profiles - advanced filtering, sorting, pagination
router.get('/', async (req: AuthRequest, res: Response) => {
  // Build filters from query
  const filters: any = {};
  const allowedFilters = ['gender', 'age_group', 'country_id', 'min_age', 'max_age', 'min_gender_probability', 'min_country_probability'];
  for (const key of allowedFilters) {
    if (req.query[key] !== undefined) {
      filters[key] = req.query[key];
    }
  }
  const page = parseInt(req.query.page as string) || 1;
  const limit = Math.min(parseInt(req.query.limit as string) || 10, 50);
  const sort_by = (req.query.sort_by as string) || 'created_at';
  const order = (req.query.order as string) === 'asc' ? 'asc' : 'desc';

  const { data, total } = await profileModel.getProfiles(filters, page, limit, sort_by, order);
  const totalPages = Math.ceil(total / limit);
  const baseUrl = `${req.protocol}://${req.get('host')}/api/profiles`;
  const links = {
    self: `${baseUrl}?page=${page}&limit=${limit}`,
    next: page < totalPages ? `${baseUrl}?page=${page + 1}&limit=${limit}` : null,
    prev: page > 1 ? `${baseUrl}?page=${page - 1}&limit=${limit}` : null,
  };
  res.json({ status: 'success', page, limit, total, total_pages: totalPages, links, data });
});

// GET /api/profiles/search - natural language query
router.get('/search', async (req: AuthRequest, res: Response) => {
  const query = req.query.q as string;
  if (!query) throw new AppError('Missing search query', 400);
  try {
    const filters = parseNaturalQuery(query);
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 10;
    const { data, total } = await profileModel.getProfiles(filters, page, limit);
    res.json({ status: 'success', page, limit, total, data });
  } catch (err: any) {
    if (err.message === 'Unable to interpret query') {
      return res.status(400).json({ status: 'error', message: 'Unable to interpret query' });
    }
    throw err;
  }
});

// POST /api/profiles - admin only
router.post('/', authorize('admin'), async (req: AuthRequest, res: Response) => {
  const { name } = req.body;
  if (!name) throw new AppError('Name is required', 400);
  const enrichment = await enrichProfile(name);
  const profile = await profileModel.createProfile({ name, ...enrichment });
  res.status(201).json({ status: 'success', data: profile });
});

// GET /api/profiles/:id
router.get('/:id', async (req: AuthRequest, res: Response) => {
  const profile = await profileModel.getProfileById(req.params.id);
  if (!profile) throw new AppError('Profile not found', 404);
  res.json({ status: 'success', data: profile });
});

// GET /api/profiles/export
router.get('/export', async (req: AuthRequest, res: Response) => {
  // Support format=csv, with same filters as list
  const format = req.query.format as string;
  if (!format || format !== 'csv') throw new AppError('Only CSV export supported', 400);
  // Build filters and sorting from query
  const filters: any = {};
  // same as list
  const { data } = await profileModel.getProfiles(filters, 1, 10000, 'created_at', 'desc'); // all for export
  // generate CSV
  const { Parser } = require('json2csv');
  const fields = ['id', 'name', 'gender', 'gender_probability', 'age', 'age_group', 'country_id', 'country_name', 'country_probability', 'created_at'];
  const parser = new Parser({ fields });
  const csv = parser.parse(data);
  res.header('Content-Type', 'text/csv');
  res.attachment(`profiles_${Date.now()}.csv`);
  res.send(csv);
});

export default router;