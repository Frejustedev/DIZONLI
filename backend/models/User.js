const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  firebaseUid: {
    type: String,
    required: true,
    unique: true
  },
  email: {
    type: String,
    required: true,
    unique: true,
    lowercase: true,
    trim: true
  },
  name: {
    type: String,
    required: true,
    trim: true
  },
  photoUrl: {
    type: String,
    default: null
  },
  age: {
    type: Number,
    required: true
  },
  gender: {
    type: String,
    enum: ['Homme', 'Femme'],
    required: true
  },
  location: {
    type: String,
    required: true
  },
  dailyGoal: {
    type: Number,
    default: 10000
  },
  userLevel: {
    type: String,
    enum: ['Bronze', 'Silver', 'Gold', 'Champion'],
    default: 'Bronze'
  },
  totalSteps: {
    type: Number,
    default: 0
  },
  totalDistance: {
    type: Number,
    default: 0
  },
  totalCalories: {
    type: Number,
    default: 0
  },
  groupIds: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Group'
  }],
  badges: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Badge'
  }],
  isActive: {
    type: Boolean,
    default: true
  }
}, {
  timestamps: true
});

// Update user level based on total steps
userSchema.methods.updateLevel = function() {
  if (this.totalSteps >= 1000000) {
    this.userLevel = 'Champion';
  } else if (this.totalSteps >= 500000) {
    this.userLevel = 'Gold';
  } else if (this.totalSteps >= 100000) {
    this.userLevel = 'Silver';
  } else {
    this.userLevel = 'Bronze';
  }
};

module.exports = mongoose.model('User', userSchema);

