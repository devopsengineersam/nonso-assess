# Use an official Node.js runtime as the base image
FROM node:16

# Set the working directory in the container
WORKDIR /app

# Copy package.json and package-lock.json to the working directory
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code
COPY . .

# Expose the port the app will run on
EXPOSE ${PORT}

# Set environment variables
ENV PORT=${PORT}
ENV API_HOST=${API_HOST}

# Command to run the application
CMD ["npm", "start"]