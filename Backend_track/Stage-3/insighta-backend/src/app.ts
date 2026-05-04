import express from 'express';
import cors from 'cors';
import cookieParser from 'cookie-parser';
import { config } from './config';
import { requestLogger } from './middleware/requestLogger';
import { errorHandler } from './middleware/errorHandler'; // we'll define a global error handler
import authRoutes from './routes/auth';
import profileRoutes from './routes/profiles';

const app = express();

app.use(cors({ origin: config.corsOrigin, credentials: true }));
app.use(express.json());
app.use(cookieParser());
app.use(requestLogger);

app.use('/auth', authRoutes);
app.use('/api/profiles', profileRoutes);

// Global error handler
app.use((err: any, req: any, res: any, next: any) => {
  const statusCode = err.statusCode || 500;
  res.status(statusCode).json({ status: 'error', message: err.message || 'Internal server error' });
});

export default app;