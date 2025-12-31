# Matrix Calculator Pro

A robust, offline-first linear algebra toolkit built with Flutter. Designed for students and engineers who need precise matrix computations without relying on internet connectivity.

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![License](https://img.shields.io/github/license/Taher-awad/matrix-calc-offline?style=for-the-badge)

## Features

### 🧮 Core Matrix Operations
- **Basic Arithmetic**: Addition (`A+B`), Subtraction (`A-B`), Multiplication (`AxB`).
- **Unary Operations**: Transpose, Inverse (Square matrices), Rank, Determinant.
- **Scalar Operations**: Scalar multiplication (`k*A`) and Matrix Power (`A^n`).
- **Precision**: Uses the `fraction` package to handle calculations with exact rational numbers, eliminating floating-point errors.

### 📐 System Solvers
Solve systems of linear equations (`Ax = B`) using multiple methods:
- **Gaussian Elimination**: Row reduction to finding solutions.
- **Gauss-Jordan**: Reduces to Reduced Row Echelon Form (RREF).
- **Cramer's Rule**: Determinant-based solution for square systems.
- **Inverse Matrix Method**: Solves `X = A⁻¹B`.
- **Least Squares**: Finds approximate solutions for overdetermined systems.

### 📊 Advanced Analysis
- **Eigenvalues & Eigenvectors**: Computes characteristic polynomials and vectors.
- **Diagonalization**: Decomposes matrices into `PDP⁻¹`.
- **Step-by-Step Explanations**: Provides detailed logic for Determinants and Eigenvalue calculations (optimized for 2x2 and 3x3 matrices).

### 💾 Productivity
- **Persistent History**: Automatically saves calculations locally.
- **Data Reusability**: Quickly load past results into input fields (`To Ops A`, `To Ops B`).
- **Offline Capable**: Fully functional without network access.

## Tech Stack

- **Framework**: [Flutter](https://flutter.dev/) (Dart)
- **State Management**: `setState` with localized logic controllers.
- **Math Engine**:
  - `fraction`: For high-precision arithmetic.
  - `math_expressions`: For variable parsing and symbolic logic.
- **Persistence**: `shared_preferences`.

## Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Taher-awad/matrix-calc-offline.git
   cd matrix-calc-offline
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## Releases

The latest APK can be downloaded from the [Releases](https://github.com/Taher-awad/matrix-calc-offline/releases) page.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

Distributed under the MIT License. See `LICENSE` for more information.
