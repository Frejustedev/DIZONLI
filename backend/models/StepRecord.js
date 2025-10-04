const mongoose = require('mongoose');

const stepRecordSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  steps: {
    type: Number,
    required: true,
    default: 0
  },
  distance: {
    type: Number,
    required: true,
    default: 0
  },
  calories: {
    type: Number,
    required: true,
    default: 0
  },
  date: {
    type: Date,
    required: true
  },
  timestamp: {
    type: Date,
    default: Date.now
  }
}, {
  timestamps: true
});

// Index for efficient querying
stepRecordSchema.index({ userId: 1, date: 1 });

// Calculate distance from steps (0.762 meters per step)
stepRecordSchema.statics.calculateDistance = function(steps) {
  return steps * 0.762;
};

// Calculate calories from steps (0.04 calories per step)
stepRecordSchema.statics.calculateCalories = function(steps) {
  return Math.round(steps * 0.04);
};

module.exports = mongoose.model('StepRecord', stepRecordSchema);

