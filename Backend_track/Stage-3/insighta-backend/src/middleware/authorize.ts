import { Response, NextFunction } from 'express';
import { AuthRequest } from './authenticate';
import { AppError } from '../utils/errors';

export function authorize(...roles: string[]) {
  return (req: AuthRequest, res: Response, next: NextFunction) => {
    if (!req.userRole || !roles.includes(req.userRole)) {
      throw new AppError('Forbidden: insufficient permissions', 403);
    }
    next();
  };
}