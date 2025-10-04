# DIZONLI Backend API

Backend API server for the DIZONLI mobile application, built with Node.js, Express, and MongoDB.

## 🚀 Quick Start

### Prerequisites
- Node.js >= 14.0.0
- MongoDB >= 4.4
- npm or yarn

### Installation

1. Navigate to backend directory:
```bash
cd backend
```

2. Install dependencies:
```bash
npm install
```

3. Configure environment variables:
```bash
cp env.example .env
# Edit .env with your configuration
```

4. Start MongoDB (if running locally):
```bash
mongod
```

5. Start the server:
```bash
# Development mode with auto-reload
npm run dev

# Production mode
npm start
```

The server will start on `http://localhost:5000`

## 📁 Project Structure

```
backend/
├── models/
│   ├── User.js
│   ├── Group.js
│   ├── StepRecord.js
│   ├── Challenge.js
│   └── Post.js
├── routes/
│   ├── auth.js
│   ├── users.js
│   ├── groups.js
│   ├── challenges.js
│   ├── steps.js
│   └── social.js
├── middleware/
│   ├── auth.js
│   └── validate.js
├── controllers/
│   └── ...
├── config/
│   └── firebase.js
├── utils/
│   └── helpers.js
├── server.js
└── package.json
```

## 🔌 API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user
- `POST /api/auth/logout` - Logout user
- `GET /api/auth/me` - Get current user

### Users
- `GET /api/users/:id` - Get user by ID
- `PUT /api/users/:id` - Update user
- `GET /api/users/:id/stats` - Get user statistics

### Groups
- `GET /api/groups` - Get all groups
- `POST /api/groups` - Create group
- `GET /api/groups/:id` - Get group by ID
- `PUT /api/groups/:id` - Update group
- `DELETE /api/groups/:id` - Delete group
- `POST /api/groups/:id/join` - Join group
- `POST /api/groups/:id/leave` - Leave group

### Steps
- `POST /api/steps` - Record steps
- `GET /api/steps/today` - Get today's steps
- `GET /api/steps/history` - Get step history
- `GET /api/steps/stats` - Get statistics

### Challenges
- `GET /api/challenges` - Get all challenges
- `POST /api/challenges` - Create challenge
- `GET /api/challenges/:id` - Get challenge by ID
- `POST /api/challenges/:id/join` - Join challenge
- `GET /api/challenges/:id/leaderboard` - Get leaderboard

### Social
- `GET /api/social/feed` - Get social feed
- `POST /api/social/posts` - Create post
- `POST /api/social/posts/:id/like` - Like post
- `POST /api/social/posts/:id/comment` - Comment on post

## 🔐 Authentication

The API uses Firebase Authentication for user management. Include the Firebase ID token in the Authorization header:

```
Authorization: Bearer <firebase_id_token>
```

## 📊 Database Models

### User
```javascript
{
  firebaseUid: String,
  email: String,
  name: String,
  age: Number,
  gender: String,
  location: String,
  dailyGoal: Number,
  userLevel: String,
  totalSteps: Number,
  totalDistance: Number,
  totalCalories: Number,
  groupIds: [ObjectId],
  badges: [ObjectId]
}
```

### Group
```javascript
{
  name: String,
  description: String,
  type: String, // 'friends', 'community', 'institution'
  adminId: ObjectId,
  members: [{ userId: ObjectId, joinedAt: Date }],
  totalSteps: Number,
  inviteCode: String
}
```

### StepRecord
```javascript
{
  userId: ObjectId,
  steps: Number,
  distance: Number,
  calories: Number,
  date: Date,
  timestamp: Date
}
```

## 🛡️ Security

- Helmet.js for security headers
- CORS configuration
- JWT token validation
- Input validation with express-validator
- MongoDB injection prevention

## 📝 Environment Variables

See `env.example` for all available configuration options.

## 🧪 Testing

```bash
npm test
```

## 📦 Deployment

### Using Docker
```bash
docker build -t dizonli-backend .
docker run -p 5000:5000 dizonli-backend
```

### Using Heroku
```bash
heroku create dizonli-api
git push heroku main
```

## 📞 Support

For issues and questions, please open an issue on GitHub.

## 📄 License

MIT License

