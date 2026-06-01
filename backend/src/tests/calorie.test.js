const { computeCalories } = require('../controllers/calorieController');

describe('Unit Test: computeCalories (PBI-1 Subtask 6)', () => {
  // Test case 1: Skenario normal dengan angka bulat
  test('harus menghitung kalori dengan benar untuk durasi dan MET standar', () => {
    // Rumus: 30 * (5 * 3.5 * 70) / 200 = 30 * 1225 / 200 = 183.75
    const result = computeCalories(30, 5, 70);
    expect(result).toBe(183.75);
  });

  // Test case 2: Pembulatan ke 2 desimal
  test('harus membulatkan hasil ke 2 tempat desimal', () => {
    // Rumus: 45 * (4.25 * 3.5 * 65.5) / 200 = 45 * 974.3125 / 200 = 219.2203125
    // Dibulatkan menjadi 219.22
    const result = computeCalories(45, 4.25, 65.5);
    expect(result).toBe(219.22);
  });

  // Test case 3: Validasi error jika durasi <= 0
  test('harus melempar error jika durasi latihan 0 atau negatif', () => {
    expect(() => computeCalories(0, 5, 70)).toThrow('Durasi latihan harus lebih dari 0 menit.');
    expect(() => computeCalories(-10, 5, 70)).toThrow('Durasi latihan harus lebih dari 0 menit.');
  });

  // Test case 4: Validasi error jika MET <= 0
  test('harus melempar error jika nilai MET 0 atau negatif', () => {
    expect(() => computeCalories(30, 0, 70)).toThrow('Nilai MET harus lebih dari 0.');
    expect(() => computeCalories(30, -1.5, 70)).toThrow('Nilai MET harus lebih dari 0.');
  });

  // Test case 5: Validasi error jika berat badan <= 0
  test('harus melempar error jika berat badan 0 atau negatif', () => {
    expect(() => computeCalories(30, 5, 0)).toThrow('Berat badan harus lebih dari 0 kg.');
    expect(() => computeCalories(30, 5, -50)).toThrow('Berat badan harus lebih dari 0 kg.');
  });
});
