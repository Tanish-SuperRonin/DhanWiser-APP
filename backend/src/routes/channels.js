import express from 'express';
import { channelController } from '../controllers/channelController.js';
import { authenticateToken } from '../middleware/auth.js';
import { body } from 'express-validator';
import { validate } from '../middleware/validation.js';

const router = express.Router();

// All routes require authentication
router.use(authenticateToken);

// Validation
const createChannelValidation = [
  body('serverId').isInt({ min: 1 }).withMessage('Valid server ID required'),
  body('name').trim().isLength({ min: 1, max: 100 }).withMessage('Channel name required'),
  body('description').optional().trim().isLength({ max: 500 })
];

// Routes
router.post('/', createChannelValidation, validate, channelController.createChannel);
router.get('/server/:serverId', channelController.getServerChannels);
router.delete('/:id', channelController.deleteChannel);

export default router;