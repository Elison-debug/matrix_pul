import numpy as np

# 参数定义
H, W = 28, 28
K = 3
INPUT_BITS = 8
OUTPUT_BITS = 20

def gen_random_input(h, w, bits):
    return np.random.randint(0, 2 ** bits, size=(h, w), dtype=np.uint8)

def gen_random_filter(k, bits):
    return np.random.randint(0, 2 ** bits, size=(k, k), dtype=np.uint8)

def conv2d_zeropad_stride1(input_matrix, kernel):
    padded = np.pad(input_matrix, pad_width=1, mode='constant', constant_values=0)
    output = np.zeros_like(input_matrix, dtype=np.uint32)
    for i in range(input_matrix.shape[0]):
        for j in range(input_matrix.shape[1]):
            region = padded[i:i+3, j:j+3]
            output[i, j] = np.sum(region * kernel, dtype=np.uint32)
    return output


def save_matrix_flat(matrix_list, filename, mode='dec', bitwidth=8):
    """将多个矩阵按行优先保存为一维文件"""
    with open(filename, 'w') as f:
        for mat in matrix_list:
            for row in mat:
                for val in row:
                    if mode == 'dec':
                        f.write(f"{val}\n")
                    elif mode == 'bin':
                        f.write(f"{format(val, f'0{bitwidth}b')}\n")


def save_as_c_header(input0, input1, filt0, filt1, filename="conv_input_data.h"):
    def matrix_to_c_array(name, mat):
        lines = [f"uint8_t {name}[{mat.shape[0]}][{mat.shape[1]}] = {{"]
        for row in mat:
            line = "    {" + ", ".join(map(str, row)) + "},"
            lines.append(line)
        lines.append("};\n")
        return "\n".join(lines)

    with open(filename, 'w') as f:
        f.write("#ifndef CONV_INPUT_DATA_H\n#define CONV_INPUT_DATA_H\n\n#include <stdint.h>\n\n")
        f.write(matrix_to_c_array("input_ch0", input0))
        f.write(matrix_to_c_array("input_ch1", input1))
        f.write(matrix_to_c_array("filter_ch0", filt0))
        f.write(matrix_to_c_array("filter_ch1", filt1))
        f.write("#endif // CONV_INPUT_DATA_H\n")

# ==== 主程序 ====

# 生成输入矩阵和滤波器
input_ch0 = gen_random_input(H, W, INPUT_BITS)
input_ch1 = gen_random_input(H, W, INPUT_BITS)
filter_ch0 = gen_random_filter(K, INPUT_BITS)
filter_ch1 = gen_random_filter(K, INPUT_BITS)

# 保存输入矩阵
save_matrix_flat([input_ch0, input_ch1], "input_matrix_all_dec.txt", mode='dec', bitwidth=INPUT_BITS)
save_matrix_flat([input_ch0, input_ch1], "input_matrix_all_bin.txt", mode='bin', bitwidth=INPUT_BITS)

# 保存滤波器
save_matrix_flat([filter_ch0, filter_ch1], "filter_matrix_all_dec.txt", mode='dec', bitwidth=INPUT_BITS)
save_matrix_flat([filter_ch0, filter_ch1], "filter_matrix_all_bin.txt", mode='bin', bitwidth=INPUT_BITS)

# 卷积运算
conv_out_ch0 = conv2d_zeropad_stride1(input_ch0, filter_ch0)
conv_out_ch1 = conv2d_zeropad_stride1(input_ch1, filter_ch1)

# 保存：conv输出 ch0 和 ch1 合并到一个文件
save_matrix_flat([conv_out_ch0, conv_out_ch1], "conv_output_all_dec.txt", mode='dec', bitwidth=OUTPUT_BITS)
save_matrix_flat([conv_out_ch0, conv_out_ch1], "conv_output_all_bin.txt", mode='bin', bitwidth=OUTPUT_BITS)

# 额外：保存 C 语言数组
save_as_c_header(input_ch0, input_ch1, filter_ch0, filter_ch1)
