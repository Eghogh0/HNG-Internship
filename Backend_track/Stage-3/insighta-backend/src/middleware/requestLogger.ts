import morgan from 'morgan';

const logFormat = ':method :url :status :response-time ms';
export const requestLogger = morgan(logFormat);