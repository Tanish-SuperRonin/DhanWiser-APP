# DhanWiser Backend

Backend API for DhanWiser - A smart group expense and settlement management system.

## Features

- 🔐 JWT Authentication (Signup, Login, Refresh Tokens)
- 👥 User Management (Profiles, Global Search)
- 🏢 Server/Group Management (Create, Invite, Join)
- 📁 Channel Organization
- 💰 Expense Tracking & Splitting
- 📊 Automatic Balance Calculation
- 💸 Settlement Suggestions

## Tech Stack

- **Node.js** + **Express.js**
- **PostgreSQL** database
- **JWT** for authentication
- **bcrypt** for password hashing

## Setup

1. Clone the repository
```bash
git clone https://github.com/YOUR_USERNAME/dhanwiser-backend.git
cd dhanwiser-backend
```

2. Install dependencies
```bash
npm install
```

3. Create PostgreSQL database
```bash
createdb dhanwiser
psql -d dhanwiser -f schema.sql
```

4. Configure environment variables
```bash
cp .env.example .env
# Edit .env with your actual values
```

5. Run the server
```bash
npm run dev
```

Server will run on http://localhost:5000

## API Endpoints

### Authentication
- `POST /api/auth/signup` - Register new user
- `POST /api/auth/login` - Login
- `POST /api/auth/refresh` - Refresh access token
- `POST /api/auth/logout` - Logout

### Users
- `GET /api/users/profile` - Get your profile
- `PUT /api/users/profile` - Update profile
- `GET /api/users/search?query=` - Search users
- `GET /api/users/:id` - Get user profile

### Servers
- `POST /api/servers` - Create server
- `GET /api/servers` - Get your servers
- `GET /api/servers/:id` - Get server details
- `POST /api/servers/invite` - Invite user
- `GET /api/servers/invitations` - Get invitations
- `POST /api/servers/invitations/:id/respond` - Accept/reject invitation

### Channels
- `POST /api/channels` - Create channel
- `GET /api/channels/server/:serverId` - Get channels

### Expenses
- `POST /api/expenses` - Add expense
- `GET /api/expenses/channel/:channelId` - Get channel expenses
- `GET /api/expenses/server/:serverId` - Get server expenses
- `GET /api/expenses/server/:serverId/balances` - Calculate balances

## Project Structure
```
dhanwiser-backend/
├── src/
│   ├── config/          # Database config
│   ├── controllers/     # Request handlers
│   ├── middleware/      # Auth, validation
│   ├── routes/          # API routes
│   ├── services/        # Business logic
│   └── app.js           # Express app
├── .env.example         # Environment template
├── .gitignore
├── package.json
└── server.js            # Entry point
```

## Contributors

- Sohil Nayi
- Tanish Shah

## License

MIT