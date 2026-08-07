import express from 'express';
import { expenseController } from '../controllers/expenseController.js';
import { authenticateToken } from '../middleware/auth.js';
import { body } from 'express-validator';
import { validate } from '../middleware/validation.js';

const router = express.Router();

// All routes require authentication
router.use(authenticateToken);

// Validation
const addExpenseValidation = [
  body('channelId').isInt({ min: 1 }).withMessage('Valid channel ID required'),
  body('title').trim().isLength({ min: 1, max: 200 }).withMessage('Title required'),
  body('totalAmount').isFloat({ min: 0.01 }).withMessage('Valid amount required'),
  body('expenseDate').isISO8601().withMessage('Valid date required'),
  body('participants').isArray({ min: 1 }).withMessage('At least one participant required'),
  body('participants.*.userId').isInt({ min: 1 }),
  body('participants.*.amountPaid').isFloat({ min: 0 }),
  body('participants.*.amountOwed').isFloat({ min: 0 })
];

// Routes
router.post('/', addExpenseValidation, validate, expenseController.addExpense);
router.get('/channel/:channelId', expenseController.getChannelExpenses);
router.get('/server/:serverId', expenseController.getServerExpenses);
router.get('/server/:serverId/balances', expenseController.getServerBalances);
router.delete('/:expenseId', expenseController.deleteExpense);

export default router;