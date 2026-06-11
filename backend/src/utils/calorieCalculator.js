/**
 * utilitas untuk menghitung BMR dan TDEE
 * Rumus yang digunakan: Mifflin-St Jeor Equation
 */

/**
 * Menghitung Basal Metabolic Rate (BMR)
 * @param {number} weight - Berat badan dalam kg
 * @param {number} height - Tinggi badan dalam cm
 * @param {number} age - Umur dalam tahun
 * @param {string} gender - Jenis kelamin ('male' atau 'female')
 * @returns {number} Nilai BMR
 */
const calculateBMR = (weight, height, age, gender) => {
  if (!weight || !height || !age || !gender) {
    throw new Error('Data fisik tidak lengkap untuk menghitung BMR');
  }

  const w = parseFloat(weight);
  const h = parseFloat(height);
  const a = parseInt(age, 10);
  const g = gender.toLowerCase();

  let bmr = (10 * w) + (6.25 * h) - (5 * a);

  if (g === 'male' || g === 'pria' || g === 'laki-laki') {
    bmr += 5;
  } else if (g === 'female' || g === 'wanita' || g === 'perempuan') {
    bmr -= 161;
  } else {
    // Default fallback, average of male and female offset
    bmr -= 78;
  }

  return Math.round(bmr);
};

/**
 * Menghitung Total Daily Energy Expenditure (TDEE)
 * @param {number} bmr - Nilai Basal Metabolic Rate
 * @param {string} activityLevel - Tingkat aktivitas (sedentary, light, moderate, active, very_active)
 * @returns {number} Nilai TDEE
 */
const calculateTDEE = (bmr, activityLevel) => {
  let multiplier = 1.2; // default sedentary

  switch (activityLevel?.toLowerCase()) {
    case 'sedentary':
    case 'sangat_ringan':
      multiplier = 1.2;
      break;
    case 'light':
    case 'ringan':
      multiplier = 1.375;
      break;
    case 'moderate':
    case 'sedang':
      multiplier = 1.55;
      break;
    case 'active':
    case 'berat':
      multiplier = 1.725;
      break;
    case 'very_active':
    case 'sangat_berat':
      multiplier = 1.9;
      break;
    default:
      multiplier = 1.2; // fallback
      break;
  }

  return Math.round(bmr * multiplier);
};

module.exports = {
  calculateBMR,
  calculateTDEE
};
