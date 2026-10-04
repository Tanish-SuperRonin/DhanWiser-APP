// Validation utility functions

export const validators = {
  // Validate expense participants sum to total amount
  validateExpenseSplit(participants, totalAmount) {
    if (!participants || participants.length === 0) {
      return {
        valid: false,
        error: 'At least one participant is required'
      };
    }

    // Calculate sum of amounts owed
    const sumOwed = participants.reduce((sum, p) => sum + (parseFloat(p.amountOwed) || 0), 0);
    const sumPaid = participants.reduce((sum, p) => sum + (parseFloat(p.amountPaid) || 0), 0);

    // Check if amounts owed sum to total (with 0.01 tolerance for rounding)
    if (Math.abs(sumOwed - totalAmount) > 0.01) {
      return {
        valid: false,
        error: `Participants' shares (₹${sumOwed.toFixed(2)}) must equal total amount (₹${totalAmount.toFixed(2)})`
      };
    }

    // Check if at least someone paid
    if (sumPaid === 0) {
      return {
        valid: false,
        error: 'At least one participant must have paid something'
      };
    }

    // Check if total paid matches total amount (with tolerance)
    if (Math.abs(sumPaid - totalAmount) > 0.01) {
      return {
        valid: false,
        error: `Total paid (₹${sumPaid.toFixed(2)}) must equal total amount (₹${totalAmount.toFixed(2)})`
      };
    }

    // Check for negative amounts
    for (const p of participants) {
      if (p.amountPaid < 0 || p.amountOwed < 0) {
        return {
          valid: false,
          error: 'Amounts cannot be negative'
        };
      }
    }

    // Check for duplicate participants
    const userIds = participants.map(p => p.userId);
    const uniqueUserIds = new Set(userIds);
    if (userIds.length !== uniqueUserIds.size) {
      return {
        valid: false,
        error: 'Cannot add the same participant twice'
      };
    }

    return { valid: true };
  },

  // Validate settlement amount
  validateSettlementAmount(amount) {
    const numAmount = parseFloat(amount);

    if (isNaN(numAmount)) {
      return {
        valid: false,
        error: 'Invalid amount'
      };
    }

    if (numAmount <= 0) {
      return {
        valid: false,
        error: 'Settlement amount must be greater than 0'
      };
    }

    if (numAmount > 1000000) {
      return {
        valid: false,
        error: 'Settlement amount cannot exceed ₹10,00,000'
      };
    }

    return { valid: true };
  },

  // Validate expense amount
  validateExpenseAmount(amount) {
    const numAmount = parseFloat(amount);

    if (isNaN(numAmount)) {
      return {
        valid: false,
        error: 'Invalid amount'
      };
    }

    if (numAmount <= 0) {
      return {
        valid: false,
        error: 'Expense amount must be greater than 0'
      };
    }

    if (numAmount > 10000000) {
      return {
        valid: false,
        error: 'Expense amount cannot exceed ₹1,00,00,000'
      };
    }

    return { valid: true };
  },

  // Validate date (not too far in past or future)
  validateExpenseDate(dateString) {
    const date = new Date(dateString);
    const now = new Date();
    const oneYearAgo = new Date();
    oneYearAgo.setFullYear(now.getFullYear() - 1);
    const oneMonthFuture = new Date();
    oneMonthFuture.setMonth(now.getMonth() + 1);

    if (isNaN(date.getTime())) {
      return {
        valid: false,
        error: 'Invalid date format'
      };
    }

    if (date < oneYearAgo) {
      return {
        valid: false,
        error: 'Expense date cannot be more than 1 year in the past'
      };
    }

    if (date > oneMonthFuture) {
      return {
        valid: false,
        error: 'Expense date cannot be more than 1 month in the future'
      };
    }

    return { valid: true };
  },

  // Validate username format
  validateUsername(username) {
    if (!username || username.length < 3) {
      return {
        valid: false,
        error: 'Username must be at least 3 characters'
      };
    }

    if (username.length > 50) {
      return {
        valid: false,
        error: 'Username cannot exceed 50 characters'
      };
    }

    // Only alphanumeric and underscore
    if (!/^[a-zA-Z0-9_]+$/.test(username)) {
      return {
        valid: false,
        error: 'Username can only contain letters, numbers, and underscores'
      };
    }

    return { valid: true };
  },

  // Validate email format
  validateEmail(email) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    
    if (!email || !emailRegex.test(email)) {
      return {
        valid: false,
        error: 'Invalid email format'
      };
    }

    return { valid: true };
  },

  // Validate password strength
  validatePassword(password) {
    if (!password || password.length < 6) {
      return {
        valid: false,
        error: 'Password must be at least 6 characters'
      };
    }

    if (password.length > 100) {
      return {
        valid: false,
        error: 'Password is too long'
      };
    }

    return { valid: true };
  },

  // Validate UPI ID format
  validateUpiId(upiId) {
    if (!upiId) {
      return { valid: true }; // UPI ID is optional
    }

    // Basic UPI ID format: username@bank
    const upiRegex = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9]+$/;
    
    if (!upiRegex.test(upiId)) {
      return {
        valid: false,
        error: 'Invalid UPI ID format (should be like: user@paytm)'
      };
    }

    if (upiId.length > 100) {
      return {
        valid: false,
        error: 'UPI ID is too long'
      };
    }

    return { valid: true };
  },

  // Validate server/channel name
  validateName(name, type = 'Name') {
    if (!name || name.trim().length === 0) {
      return {
        valid: false,
        error: `${type} is required`
      };
    }

    if (name.length > 100) {
      return {
        valid: false,
        error: `${type} cannot exceed 100 characters`
      };
    }

    return { valid: true };
  },

  // Validate description
  validateDescription(description) {
    if (description && description.length > 500) {
      return {
        valid: false,
        error: 'Description cannot exceed 500 characters'
      };
    }

    return { valid: true };
  }
};