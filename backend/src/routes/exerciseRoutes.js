const express = require('express');
const router = express.Router();
const { getExercises } = require('../controllers/exerciseController');

router.get('/exercise-catalogue', getExercises);

module.exports = router;