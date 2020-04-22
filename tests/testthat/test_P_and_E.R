test_that("P and E are working", {

  dat <<- expand.grid(Y = c(0, 1), A = c(0, 1), X = c(0, 1), N = 1)
  tol <- 10^-10

  #
  expect_equal(P(Y == 0), 0.5)
  expect_equal(P(Y == 0, A == 1), 0.5)
  expect_equal(P(Y == 0 | A == 1), 0.5)
  expect_equal(P(Y | A == 1, X), rep(0.5, 4))
  expect_equal(E(Y), 0.5)
  expect_equal(E(Y, A == 1), 0.5)
  expect_equal(E(Y | A == 1), 0.5)
  expect_equal(E(Y | A == 1, X), rep(0.5, 2))

  dat$N <<- c(756, 84, 304, 256, 720, 80, 220, 580)

  expect_true(abs(P(A == 0 | X == 0) - 0.6) < tol)
  expect_true(abs(P(A == 0, X == 0) - 0.6) < tol)
  expect_true(abs(E(A | X == 0) - 0.4) < tol)
  expect_true(abs(E(A, X == 0) - 0.4) < tol)
  expect_true(abs(P(X == 0) - 7/15) < tol)
  expect_true(abs(E(X) - 8/15) < tol)
  expect_true(abs(E(Y, X == 0, A == 0) - 0.1) < tol)
  expect_true(abs(sum(P(X) * E(Y | X, A == 0)) * P(A == 0 | X == 1) +
                    sum(P(X) * E(Y | X, A == 1)) * P(A == 1 | X == 1)
              - 0.35) < tol)

  dat <<- dat[rep(1:8, times = dat$N), ]
  dat <<- dat[, -4] # Drop the "N" column.
  expect_true(abs(P(A == 0 | X == 0) - 0.6) < tol)
  expect_true(abs(P(A == 0, X == 0) - 0.6) < tol)
  expect_true(abs(E(A | X == 0) - 0.4) < tol)
  expect_true(abs(E(A, X == 0) - 0.4) < tol)
  expect_true(abs(P(X == 0) - 7/15) < tol)
  expect_true(abs(E(X) - 8/15) < tol)
  expect_true(abs(E(Y, X == 0, A == 0) - 0.1) < tol)
  expect_true(abs(sum(P(X) * E(Y | X, A == 0)) * P(A == 0 | X == 1) +
                    sum(P(X) * E(Y | X, A == 1)) * P(A == 1 | X == 1)
                  - 0.35) < tol)

  dat <<- expand.grid(Y = c(0, 1), A = c(0, 1), X = c(0, 1), N = 1)
  dat <<- dat[, -4] # Drop the "N" column.
  expect_equal(P(Y == 0), 0.5)
  expect_equal(P(Y == 0, A == 1), 0.5)
  expect_equal(P(Y == 0 | A == 1), 0.5)
  expect_equal(P(Y | A == 1, X), rep(0.5, 4))
  expect_equal(E(Y), 0.5)
  expect_equal(E(Y, A == 1), 0.5)
  expect_equal(E(Y | A == 1), 0.5)
  expect_equal(E(Y | A == 1, X), rep(0.5, 2))
})
