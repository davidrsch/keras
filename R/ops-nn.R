#' Normalizes `x` by `mean` and `variance`.
#'
#' @description
#' This op is typically used by the batch normalization step in a neural
#' network. It normalizes the input tensor along the given axis.
#'
#' # Examples
#' ```{r}
#' x <- op_convert_to_tensor(rbind(c(0.1, 0.2, 0.3),
#'                                 c(0.4, 0.5, 0.6),
#'                                 c(0.7, 0.8, 0.9)))
#' op_batch_normalization(
#'   x,
#'   mean = c(0.4, 0.5, 0.6),
#'   variance = c(0.67, 0.67, 0.67),
#'   axis = -1
#' )
#' ```
#'
#' @returns
#' The normalized tensor.
#'
#' @param x
#' Input tensor.
#'
#' @param mean
#' A mean vector of the same length as the `axis` dimension of the
#' input thensor.
#'
#' @param variance
#' A variance vector of the same length as the `axis` dimension
#' of the input tensor.
#'
#' @param axis
#' Integer, the axis that should be normalized.
#'
#' @param offset
#' An offset vector of the same length as the `axis` dimension of
#' the input tensor. If not `NULL`, `offset` is added to the normalized
#' tensor. Defaults to `NULL`.
#'
#' @param scale
#' A scale vector of the same length as the `axis` dimension of the
#' input tensor. If not `NULL`, the normalized tensor is multiplied by
#' `scale`. Defaults to `NULL`.
#'
#' @param epsilon
#' Small float added to variance to avoid dividing by zero.
#' Defaults to 1e-3.
#'
#' @export
#' @family nn ops
#' @family ops
#' @tether keras.ops.batch_normalization
#' @seealso
#' + <https://www.tensorflow.org/api_docs/python/tf/keras/ops/batch_normalization>
op_batch_normalization <-
function (x, mean, variance, axis, offset = NULL, scale = NULL,
    epsilon = 0.001)
{
    args <- capture_args(list(
      axis = as_axis,
      mean = as_array,
      variance = as_array,
      offset = as_array
    ))
    do.call(ops$batch_normalization, args)
}

#' Normalizes `x` over the specified axis.
#'
#' @description
#' It is defined as: `op_normalize(x) = x / max(norm(x), epsilon)`.
#'
#' # Examples
#' ```{r}
#' x <- op_convert_to_tensor(rbind(c(1, 2, 3), c(4, 5, 6)))
#' x_norm <- op_normalize(x)
#' x_norm
#' ```
#'
#' @returns
#' The normalized array.
#'
#' @param x
#' Input tensor.
#'
#' @param axis
#' The axis or axes along which to perform normalization.
#' Default to -1.
#'
#' @param order
#' The exponent value in the norm formulation.
#' Defaults to 2.
#'
#' @param epsilon
#' A lower bound value for the norm.
#' Defaults to `config_epsilon()`.
#'
#' @export
#' @family nn ops
#' @family ops
#' @tether keras.ops.normalize
#' @seealso
#' + <https://www.tensorflow.org/api_docs/python/tf/keras/ops/normalize>
op_normalize <-
function (x, axis = -1L, order = 2L, epsilon = NULL)
{
    args <- capture_args(list(axis = as_axis, order = as_integer))
    do.call(ops$normalize, args)
}


#' Peak Signal-to-Noise Ratio (PSNR) function.
#'
#' @description
#' This function computes the Peak Signal-to-Noise Ratio between two signals,
#' `x1` and `x2`. PSNR is a measure of the quality of a reconstructed signal.
#' The higher the PSNR, the closer the reconstructed signal is to the original
#' signal. Note that it can become negative when the signal power is
#' smaller that the noise power.
#'
#' # Examples
#' ```{r}
#' x1 <- random_normal(c(2, 4, 4, 3))
#' x2 <- random_normal(c(2, 4, 4, 3))
#' max_val <- 1.0
#' op_psnr(x1, x2, max_val)
#' ```
#'
#' @returns
#' float: The PSNR value between `x1` and `x2`.
#'
#' @param x1
#' The first input signal.
#'
#' @param x2
#' The second input signal. Must have the same shape as `x1`.
#'
#' @param max_val
#' The maximum possible value in the signals.
#'
#' @export
#' @family nn ops
#' @family ops
#' @tether keras.ops.psnr
op_psnr <-
function (x1, x2, max_val)
ops$psnr(x1, x2, max_val)



#' Scaled dot product attention function.
#'
#' @description
#' Computes the attention function on Q (`query`), K (`key`), and V(`value`):
#' `attention(Q, K, V) = softmax(Q * K / sqrt(d)) * V`. If we define `logits`
#' as the output of `Q * K` and the `probs` as the output of `softmax`.
#'
#' Throughout this function, we utilize the following notation to represent the
#' shape of array:
#' - B: batch size
#' - S: length of the key/value
#' - T: length of the query
#' - N: number of attention heads
#' - H: dimensions of each attention head
#' - K: number of key/value heads
#' - G: number of groups, which equals to `N // K`
#'
#' # Examples
#' ```{r}
#' query = random_normal(c(2, 4, 8, 16))
#' key = random_normal(c(2, 6, 8, 16))
#' value = random_normal(c(2, 6, 8, 16))
#' op_dot_product_attention(query, key, value) |> op_shape()
#' ```
#'
#' @returns
#' An array of the attention output with the same shape of `query`.
#'
#' @param query
#' The query array with the shape of `(B, T, N, H)`.
#'
#' @param key
#' The key array with the shape of `(B, S, K, H)`. When `K` equals
#' `N`, multi-headed attention (MHA) is performed. Otherwise, grouped
#' query attention (GQA) is performed if `N` is a multiple of `K`. and
#' multi-query attention (MQA) is performed if `K==1` (a special case
#' of GQA).
#'
#' @param value
#' The value array with the same shape of `key`.
#'
#' @param bias
#' Optional bias array to be added to logits. The shape must be
#' broadcastable to `(B, N, T, S)`.
#'
#' @param mask
#' Optional mask array used to filter out logits. It is a boolean
#' mask where `TRUE` indicates the element should take part in
#' attention. For an additive mask, users should pass it to bias. The
#' shape must be broadcastable to `(B, N, T, S)`.
#'
#' @param scale
#' Optional scale for the logits. If `NULL`, the scale will be set
#' to `1.0 / sqrt(H)`.
#'
#' @param is_causal
#' Whether to apply causal mask.
#'
#' @param flash_attention
#' Whether to use flash attention. If `NULL`, it will
#' attempt to use flash attention if the required conditions are met.
#' Typically, the inputs must be in float16 and bfloat16 dtype and the
#' input layout requirements may vary depending on the backend.
#'
#' @export
#' @tether keras.ops.dot_product_attention
#' @family nn ops
#' @family ops
op_dot_product_attention <-
function (query, key, value, bias = NULL, mask = NULL, scale = NULL,
          is_causal = FALSE, flash_attention = NULL)
{
  args <- capture_args()
  do.call(ops$dot_product_attention, args)
}





#' Gated Linear Unit (GLU) activation function.
#'
#' @description
#' It is defined as:
#'
#' `f(x) = a * sigmoid(b)`
#' where `x` is split into `a` and `b` along the given axis.
#'
#' # Examples
#' ```{r}
#' x <- op_array(c(-1., 0., 1. , 1.))
#' op_glu(x)
#' ```
#'
#' @returns
#' A tensor with the same shape as half of the input.
#'
#' @param x
#' Input tensor.
#'
#' @param axis
#' The axis along which to split the input tensor. Defaults to `-1`.
#'
#' @family nn ops
#' @family ops
#' @export
#' @tether keras.ops.glu
op_glu <-
function (x, axis = -1L)
{
    args <- capture_args(list(axis = as_axis))
    do.call(ops$glu, args)
}


#' Hard Shrink activation function.
#'
#' @description
#' The Hard Shrink function is a thresholding operation defined as:
#'
#' `f(x) = x` if `|x| > threshold`,
#' `f(x) = 0` otherwise.
#'
#' # Examples
#' ```{r}
#' x <- op_array(c(-0.5, 0., 1.))
#' op_hard_shrink(x)
#' ```
#'
#' @returns
#' A tensor with the same shape as `x`.
#'
#' @param x
#' Input tensor.
#'
#' @param threshold
#' Threshold value. Defaults to 0.5.
#'
#' @family nn ops
#' @family ops
#' @export
#' @tether keras.ops.hard_shrink
op_hard_shrink <-
function (x, threshold = 0.5)
ops$hard_shrink(x, threshold)


#' Applies the HardTanh function element-wise.
#'
#' @description
#' It is defined as:
#'
#' `f(x) = -1 for x < -1`, `f(x) = x for -1 <= x <= 1`, `f(x) = 1 for x > 1`.
#'
#' # Examples
#' ```{r}
#' x <- op_array(c(-2., -1., 0., 1., 2.))
#' op_hard_tanh(x)
#' ```
#'
#' @returns
#' Output tensor of same shape as `x`
#' where values are clamped between -1 and 1.
#'
#' @param x
#' Input tensor.
#'
#' @family nn ops
#' @family ops
#' @export
#' @tether keras.ops.hard_tanh
op_hard_tanh <-
function (x)
ops$hard_tanh(x)


#' Soft Shrink activation function.
#'
#' @description
#' It is defined as
#'
#' `f(x) = x - threshold` if `x > threshold`,
#' `f(x) = x + threshold` if `x < -threshold`,
#' `f(x) = 0` otherwise.
#'
#' # Examples
#' ```{r}
#' x <- op_array(c(-1, 0, 1))
#' op_soft_shrink(x)
#' ```
#'
#' @returns
#' A tensor with the same shape as `x`.
#'
#' @param x
#' Input tensor.
#'
#' @param threshold
#' Threshold value. Defaults to 0.5.
#'
#' @family nn ops
#' @family ops
#' @export
#' @tether keras.ops.soft_shrink
op_soft_shrink <-
function (x, threshold = 0.5)
ops$soft_shrink(x, threshold)


#' Squareplus activation function.
#'
#' @description
#' The Squareplus activation function is defined as:
#'
#' `f(x) = (x + sqrt(x^2 + b)) / 2`
#'
#' # Examples
#' ```{r}
#' x <- op_array(c(-1.0, 0.0, 1.0))
#' op_squareplus(x)
#' ```
#'
#' @returns
#' A tensor with the same shape as `x`.
#'
#' @param x
#' Input tensor.
#'
#' @param b
#' Smoothness parameter. Defaults to 4.
#'
#' @family nn ops
#' @family ops
#' @export
#' @tether keras.ops.squareplus
op_squareplus <-
function (x, b = 4L)
{
    args <- capture_args(NULL)
    do.call(ops$squareplus, args)
}


#' Applies the tanh shrink function element-wise.
#'
#' @description
#' It is defined as:
#'
#' `f(x) = x - tanh(x)`.
#'
#' # Examples
#' ```{r}
#' x <- op_array(c(-1., 0., 1.))
#' op_tanh_shrink(x)
#' ```
#'
#' @returns
#' Output tensor of the same shape as `x`, where each element is
#' transformed according to the tanh shrink operation.
#'
#' @param x
#' Input tensor.
#'
#' @family nn ops
#' @family ops
#' @export
#' @tether keras.ops.tanh_shrink
op_tanh_shrink <-
function (x)
ops$tanh_shrink(x)


#' Continuously-differentiable exponential linear unit.
#'
#' @description
#' It is defined as:
#'
#' `f(x) =  alpha * (exp(x / alpha) - 1) for x < 0`, `f(x) = x for x >= 0`.
#'
#' # Examples
#' ```{r}
#' x <- op_array(c(-1., 0., 1.))
#' op_celu(x)
#' ```
#'
#' @returns
#' A tensor with the same shape as `x`.
#'
#' @param x
#' Input tensor.
#'
#' @param alpha
#' The value for the CELU formulation. Defaults to `1.0`.
#'
#' @family nn ops
#' @family ops
#' @export
#' @tether keras.ops.celu
op_celu <-
function (x, alpha = 1)
ops$celu(x, alpha)

#' SparsePlus activation function.
#'
#' @description
#' It is defined as
#'
#' `f(x) = 0` for `x <= -1`.
#' `f(x) = (1/4) * (x + 1)^2` for `-1 < x < 1`.
#' `f(x) = x` for `x >= 1`.
#'
#' # Examples
#' ```{r}
#' x <- op_array(c(-1.0, 0.0, 1.0))
#' op_sparse_plus(x)
#' ```
#'
#' @returns
#' A tensor with the same shape as `x`.
#'
#' @param x
#' Input tensor.
#'
#' @export
#' @tether keras.ops.sparse_plus
#' @family nn ops
#' @family ops
op_sparse_plus <-
function (x)
ops$sparse_plus(x)

#' Sparsemax activation function.
#'
#' @description
#' For each batch `i`, and class `j`,
#' sparsemax activation function is defined as:
#'
#' `sparsemax(x)[i, j] = max(x[i, j] - (x[i, :]), 0).`
#'
#' # Examples
#' ```{r}
#' x <- op_array(c(-1., 0., 1.))
#' op_sparsemax(x)
#' ```
#'
#' @returns
#' A tensor, output of sparsemax transformation. Has the same type and
#' shape as `x`.
#'
#' @param x
#' Input tensor.
#'
#' @param axis
#' `int`, axis along which the sparsemax operation is applied.
#'
#' @export
#' @tether keras.ops.sparsemax
#' @family nn ops
#' @family ops
op_sparsemax <-
function (x, axis = -1L)
{
    args <- capture_args(list(axis = as_axis))
    do.call(ops$sparsemax, args)
}

#' Threshold activation function.
#'
#' @description
#' The function thresholds the input `x` as follows:
#' `f(x) = x` if `x > threshold`,
#' `f(x) = default_value` otherwise.
#'
#' # Examples
#' ```{r}
#' x <- op_array(c(-1.0, 0.0, 1.0, 2.0))
#' op_threshold(x, 1, 0)
#' ```
#'
#' @returns
#' A tensor with the same shape as `x`.
#'
#' @param x
#' Input tensor.
#'
#' @param threshold
#' The value that decides when to retain or replace x.
#'
#' @param default_value
#' Value to assign when `x <= threshold`.
#'
#' @export
#' @tether keras.ops.threshold
#' @family nn ops
#' @family ops
op_threshold <-
function (x, threshold, default_value)
ops$threshold(x, threshold, default_value)

#' Convert flat indices to coordinate arrays in a given array shape.
#'
#' @description
#'
#' # Examples
#' ```{r}
#' indices <- c(1, 5)
#' shape <- array(c(3, 3))
#' op_unravel_index(indices, shape)
#' ```
#'
#' @returns
#' Tuple of arrays for each dimension with unraveled indices.
#'
#' @param indices
#' An integer or array of integers representing flat indices.
#'
#' @param shape
#' The shape of the array to unravel into.
#'
#' @export
#' @tether keras.ops.unravel_index
#' @family nn ops
#' @family ops
op_unravel_index <-
function (indices, shape)
{
    args <- capture_args(list(indices = as_index, shape = normalize_shape))
    do.call(ops$unravel_index, args)
}

#' Constructs a complex tensor whose elements are Cartesian
#'
#' @description
#' coordinates corresponding to the polar coordinates
#' with absolute value `abs` and angle `angle`.
#'
#' The operation is numerically equivalent to `torch.polar()`.
#' It is not equivalent to `scipy.lingalg.polar()` which performs
#' Singular Value Decomposition.
#'
#' Given the magnitude (`abs_`) and angle (`angle`), this function computes the
#' corresponding complex number in the form of `real + imaginary * 1i`, where:
#' - `real = abs_ * cos(angle)`
#' - `imaginary = abs_ * sin(angle)`
#'
#' # Examples
#' ```{r}
#' abs_ <- random_normal(c(1, 2))
#' angle <- random_normal(c(1, 2))
#' op_shape(op_polar(abs_, angle))
#' op_polar(abs_, angle)
#' ```
#'
#' @returns
#' A complex number (or array of complex numbers) with the same shape as
#' `abs_` and `angle`.
#'
#' @param abs_
#' The magnitude (absolute value) of the complex number.
#'
#' @param angle
#' The angle (in radians) of the complex number.
#'
#' @export
#' @tether keras.ops.polar
#' @family nn ops
#' @family ops
op_polar <-
  function (abs_, angle)
    keras$ops$polar(abs_, angle)


#' Performs Root Mean Square (RMS) normalization on `x`.
#'
#' @description
#' The Keras operation implements the operation as described in
#' [Root Mean Square Layer Normalization](https://arxiv.org/pdf/1910.07467)
#' by Biao Zhang et al.
#'
#' The operation is different from LayerNormalization with RMS scaling.
#'
#' It is defined as `rms_normalization(x) = x * rsqrt(mean(square(x))) * scale`
#'
#' # Examples
#'
#' ```python
#' x <- random_uniform(c(1, 10))
#' x_norm <- op_rms_normalization(x, scale = 10)
#' x_norm
#' ```
#'
#' @returns
#' The normalized array.
#'
#' @param x
#' Input tensor.
#'
#' @param axis
#' The axis or axes along which to perform normalization.
#' Default to -1.
#'
#' @param scale
#' Optional scaling factor for the normalization.
#'
#' @param epsilon
#' A lower bound value for the norm.
#' Defaults to `config_epsilon()`.
#'
#' @export
#' @tether keras.ops.rms_normalization
#' @family nn ops
#' @family ops
op_rms_normalization <-
function (x, scale = 1L, axis = -1L, epsilon = NULL)
{
    args <- capture_args(list(axis = as_axis))
    do.call(keras$ops$rms_normalization, args)
}
