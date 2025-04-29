# Use official Node.js 14.17.0 base image
FROM node:14.17.0

# Set working directory inside container
WORKDIR /app

# Copy package.json and package-lock.json first
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code
COPY . .

# Expose port 3000
EXPOSE 3000

# Start the frontend server
CMD ["npm", "start"]
