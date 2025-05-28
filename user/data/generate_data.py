import numpy as np

H, W = 28, 28
K = 3
INPUT_BITS = 8
OUTPUT_BITS = 20

# === 数据生成函数 ===

def gen_random_input(h, w, bits):
    return np.random.randint(0, 2 ** bits, size=(h, w), dtype=np.uint8)

def gen_random_filter(k, bits):
    return np.random.randint(0, 2 ** bits, size=(k, k), dtype=np.uint8)

def conv2d_zeropad_stride1(input_matrix, kernel):
    H, W = input_matrix.shape
    padded = np.pad(input_matrix, ((1,1), (1,1)), mode='constant', constant_values=0)
    output = np.zeros((H, W), dtype=np.uint32)
    for i in range(H):
        for j in range(W):
            acc = 0
            for m in range(3):
                for n in range(3):
                    print(int(padded[i + m][j + n]) * int(kernel[m][n]))
                    acc += int(padded[i + m][j + n]) * int(kernel[m][n])
            output[i][j] = acc
    return output

def save_matrix_flat(matrix_list, filename, mode='dec', bitwidth=8):
    with open(filename, 'w') as f:
        for mat in matrix_list:
            for row in mat:
                for val in row:
                    val_int = int(val)
                    if mode == 'dec':
                        f.write(f"{val_int}\n")
                    elif mode == 'bin':
                        if val_int >= (1 << bitwidth):
                            print(f"⚠️ Warning: value {val_int} exceeds {bitwidth}-bit limit")
                        f.write(f"{format(val_int, f'0{bitwidth}b')}\n")

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

# 生成输入矩阵和滤波器
input_ch0 = gen_random_input(H, W, INPUT_BITS)
input_ch1 = gen_random_input(H, W, INPUT_BITS)
filter_ch0 = gen_random_filter(K, INPUT_BITS)
filter_ch1 = gen_random_filter(K, INPUT_BITS)

# 保存输入矩阵（CH0和CH1连续在一起）
save_matrix_flat([input_ch0, input_ch1], "input_dec.txt", mode='dec', bitwidth=INPUT_BITS)
save_matrix_flat([input_ch0, input_ch1], "input_bin.txt", mode='bin', bitwidth=INPUT_BITS)

# 保存滤波器（CH0和CH1连续在一起）
save_matrix_flat([filter_ch0, filter_ch1], "filter_dec.txt", mode='dec', bitwidth=INPUT_BITS)
save_matrix_flat([filter_ch0, filter_ch1], "filter_bin.txt", mode='bin', bitwidth=INPUT_BITS)

conv_out_ch0 = conv2d_zeropad_stride1(input_ch0, filter_ch0)
conv_out_ch1 = conv2d_zeropad_stride1(input_ch1, filter_ch1)

# 保存输出矩阵（CH0和CH1连续在一起）
save_matrix_flat([conv_out_ch0, conv_out_ch1], "conv_dec.txt", mode='dec', bitwidth=OUTPUT_BITS)
save_matrix_flat([conv_out_ch0, conv_out_ch1], "conv_bin.txt", mode='bin', bitwidth=OUTPUT_BITS)

# 额外：保存成 C 数组
save_as_c_header(input_ch0, input_ch1, filter_ch0, filter_ch1)
