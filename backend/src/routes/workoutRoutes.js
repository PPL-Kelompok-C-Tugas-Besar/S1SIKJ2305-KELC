const express = require('express');
const router = express.Router();
const workoutController = require('../controllers/workoutController');
const { verifyToken } = require('../middleware/authMiddleware');

// GET request to fetch all workouts
router.get('/', workoutController.getWorkouts);

// Personalized recommendations for the authenticated user
router.get('/recommended', verifyToken, workoutController.getRecommendedWorkouts);

// Saved workouts for the authenticated user
router.get('/saved', verifyToken, workoutController.getSavedWorkouts);
router.post('/:id/save', verifyToken, workoutController.saveWorkout);
router.delete('/:id/save', verifyToken, workoutController.unsaveWorkout);

// GET request to fetch exercises for a specific workout
router.get('/:id/exercises', workoutController.getWorkoutExercises);

module.exports = router;
