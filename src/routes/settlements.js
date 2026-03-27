import express from 'express';
import { settlementController } from '../controllers/settlementController.js';
import { authenticateToken } from '../middleware/auth.js';
import { body } from 'express-validator';
import { validate } from '../middleware/validation.js';

const router = express.Router();

// All routes require authentication
router.use(authenticateToken);

// Validation
const initiateSettlementValidation = [
  body('serverId').isInt({ min: 1 }).withMessage('Valid server ID required'),
  body('receiverId').isInt({ min: 1 }).withMessage('Valid receiver ID required'),
  body('amount').isFloat({ min: 0.01 }).withMessage('Valid amount required'),
  body('notes').optional().trim().isLength({ max: 500 }),
  body('proofImage').optional().isString().isLength({ max: 4000000 })
];

const rejectSettlementValidation = [
  body('reason').optional().trim().isLength({ max: 500 })
];

// Routes
router.post('/', initiateSettlementValidation, validate, settlementController.initiateSettlement);
router.get('/pending', settlementController.getMyPendingSettlements);
router.get('/server/:serverId', settlementController.getServerSettlements);
router.get('/server/:serverId/history', settlementController.getSettlementHistory);
router.post('/:id/approve', settlementController.approveSettlement);
router.post('/:id/reject', rejectSettlementValidation, validate, settlementController.rejectSettlement);

export default router;
