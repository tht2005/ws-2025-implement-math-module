/// DEX Math Module - AMM calculations
/// Contains mathematical functions for constant product AMM
module dex::math;

// ===== Constants =====
/// Fee denominator (basis points: 10000 = 100%)
const FEE_DENOMINATOR: u64 = 10000;

// ===== Error Codes =====
const E_ZERO_AMOUNT: u64 = 0;
const E_RESERVES_EMPTY: u64 = 5;

// ===== Square Root Functions =====

/// Calculate square root using Newton's method (Babylonian method)
/// Used for initial LP token calculation: LP = sqrt(x * y)
public fun sqrt(x: u64): u64 {
	if (x == 0) return 0;
	let mut y = x;
	let mut z = y / 2 + y % 2; // solve (y + 1) / 2 overflow bug
	while (z < y) {
		y = z;
		z = (z + x / z) / 2;
	};
	y
}

/// Calculate square root for u128 (for large intermediate values)
public fun sqrt_u128(x: u128): u128 {
	if (x == 0) return 0;
	let mut y = x;
	let mut z = y / 2 + y % 2;
	while (z < y) {
		y = z;
		z = (z + x / z) / 2;
	};
	y
}

// ===== Utility Functions =====

/// Return the minimum of two values
public fun min(a: u64, b: u64): u64 {
    if (a < b) { a } else { b }
}

/// Return the maximum of two values
public fun max(a: u64, b: u64): u64 {
    if (a > b) { a } else { b }
}

// ===== AMM Calculation Functions =====

/// Calculate output amount for a swap using constant product formula with fees
///
/// Formula: dy = (dx * (FEE_DENOMINATOR - fee_bps) * y) / (x * FEE_DENOMINATOR + dx * (FEE_DENOMINATOR - fee_bps))
/// For 0.3% fee: dy = (dx * 997 * y) / (x * 1000 + dx * 997)
public fun calculate_swap_output(
    amount_in: u64,
    reserve_in: u64,
    reserve_out: u64,
    fee_bps: u64,
): u64 {
	assert!(reserve_in > 0, E_RESERVES_EMPTY);
	assert!(reserve_out > 0, E_RESERVES_EMPTY);
	assert!(amount_in > 0, E_ZERO_AMOUNT);
	let dx = amount_in as u128;
	let x = reserve_in as u128;
	let y = reserve_out as u128;

	let d = FEE_DENOMINATOR as u128;
	let bps = fee_bps as u128;

	let a = dx * (d - bps) * y;
	let b = (x * d + dx * (d - bps));

	(a / b) as u64
}

/// Calculate initial LP tokens using geometric mean
/// LP = sqrt(amount_x * amount_y)
public fun calculate_initial_lp(amount_x: u64, amount_y: u64): u64 {
	sqrt(amount_x) * sqrt(amount_y)
}

/// Calculate LP tokens for subsequent deposits
/// LP = min(dx/x, dy/y) * total_lp
public fun calculate_subsequent_lp(
    amount_x: u64,
    amount_y: u64,
    reserve_x: u64,
    reserve_y: u64,
    lp_supply: u64,
): u64 {
	assert!(reserve_x > 0, E_RESERVES_EMPTY);
	assert!(reserve_y > 0, E_RESERVES_EMPTY);
	assert!(amount_x > 0, E_ZERO_AMOUNT);
	assert!(amount_y > 0, E_ZERO_AMOUNT);
	let dx = amount_x as u128;
	let dy = amount_y as u128;
	let x = reserve_x as u128;
	let y = reserve_y as u128;
	let lp = lp_supply as u128;
	// dx / x < dy / y <=> dx * y < x * dy
	if (dx * y < x * dy) {
		(dx * lp / x) as u64
	} else {
		(dy * lp / y) as u64
	}
}

/// Calculate token amounts to return when removing liquidity
/// amount_out = (lp_burned / total_lp) * reserve
public fun calculate_remove_liquidity(
    lp_amount: u64,
    lp_supply: u64,
    reserve_x: u64,
    reserve_y: u64,
): (u64, u64) {
	let burned = lp_amount as u128;
	let total = lp_supply as u128;
	let x = reserve_x as u128;
	let y = reserve_y as u128;
	let x_out = burned * x / total;
	let y_out = burned * y / total;
	(x_out as u64, y_out as u64)
}

/// Get the fee denominator constant
public fun fee_denominator(): u64 {
    FEE_DENOMINATOR
}
