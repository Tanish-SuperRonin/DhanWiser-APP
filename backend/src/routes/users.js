import express from 'express';
import { userController } from '../controllers/userController.js';
import { authenticateToken } from '../middleware/auth.js';
import { body } from 'express-validator';
import { validate } from '../middleware/validation.js';

const router = express.Router();

// Validation rules
const updateProfileValidation = [
  body('fullName')
    .optional()
    .trim()
    .isLength({ min: 1, max: 100 })
    .withMessage('Full name must be between 1 and 100 characters'),
  body('upiId')
    .optional()
    .trim()
    .isLength({ min: 3, max: 100 })
    .withMessage('UPI ID must be between 3 and 100 characters'),
  body('profilePicture')
    .optional()
    .isURL()
    .withMessage('Profile picture must be a valid URL')
];

// All routes require authentication
router.use(authenticateToken);

// Get current user's profile
router.get('/profile', userController.getMyProfile);

// Update current user's profile
router.put('/profile', updateProfileValidation, validate, userController.updateMyProfile);

// Search users globally
router.get('/search', userController.searchUsers);

// Get user by ID (public profile)
router.get('/:id', userController.getUserById);

export default router;