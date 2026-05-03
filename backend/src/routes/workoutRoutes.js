const express = require('express');
const router = express.Router();
const { getWorkouts } = require('../controllers/workoutController');

router.get('/', getWorkouts);

module.exports = router;
