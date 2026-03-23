import express from 'express';
import { serverController } from '../controllers/serverController.js';
import { authenticateToken } from '../middleware/auth.js';
import { body, param } from 'express-validator';
import { validate } from '../middleware/validation.js';

const router = express.Router();

// All routes require authentication
router.use(authenticateToken);

// Validation rules
const createServerValidation = [
  body('name')
    .trim()
    .isLength({ min: 1, max: 100 })
    .withMessage('Server name must be between 1 and 100 characters'),
  body('description')
    .optional()
    .trim()
    .isLength({ max: 500 })
    .withMessage('Description must not exceed 500 characters')
];

const inviteUserValidation = [
  body('serverId')
    .isInt({ min: 1 })
    .withMessage('Valid server ID required'),
  body('userId')
    .isInt({ min: 1 })
    .withMessage('Valid user ID required')
];

const respondInvitationValidation = [
  body('action')
    .isIn(['accept', 'reject'])
    .withMessage('Action must be either "accept" or "reject"')
];

// Routes - ORDER MATTERS!
// Specific routes FIRST, dynamic routes LAST
router.post('/', createServerValidation, validate, serverController.createServer);
router.get('/', serverController.getMyServers);

// Invitation routes (specific paths)
router.get('/invitations', serverController.getMyInvitations);
router.post('/invite', inviteUserValidation, validate, serverController.inviteUser);
router.post('/invitations/:id/respond', respondInvitationValidation, validate, serverController.respondToInvitation);

// Reminder routes
router.get('/:id/reminders/pending', serverController.getUsersNeedingReminders);
router.post('/:id/reminders/send', serverController.sendReminders);

// Dynamic :id routes (MUST BE LAST)
router.get('/:id', serverController.getServerDetails);
router.delete('/:id/leave', serverController.leaveServer);
router.delete('/:id', serverController.deleteServer);


export default router;