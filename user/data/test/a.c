#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <time.h>

#define WIDTH 28
#define HEIGHT 28
#define KERNEL_SIZE 3
#define OUT_WIDTH 28
#define OUT_HEIGHT 28

// 生成 0-255 的随机数
uint8_t rand8() {
    return rand() % 256;
}

// 输出二进制字符串
void write_binary(FILE *f, uint32_t val, int bits) {
    for (int i = bits - 1; i >= 0; i--) {
        fprintf(f, "%d", (val >> i) & 1);
    }
    fprintf(f, "\n");
}

// 计算 3x3 卷积（padding=0，stride=1）
int32_t conv2d(uint8_t input[HEIGHT][WIDTH], uint8_t kernel[KERNEL_SIZE][KERNEL_SIZE], int x, int y) {
    int32_t sum = 0;
    for (int i = 0; i < KERNEL_SIZE; i++) {
        for (int j = 0; j < KERNEL_SIZE; j++) {
            int xi = x + i - 1;
            int yj = y + j - 1;
            if (xi >= 0 && xi < HEIGHT && yj >= 0 && yj < WIDTH) {
                sum += input[xi][yj] * kernel[i][j];
            }
        }
    }
    return sum;
}

int main() {
    srand(time(NULL));

    uint8_t input_ch0[HEIGHT][WIDTH];
    uint8_t input_ch1[HEIGHT][WIDTH];
    uint8_t filter_ch0[KERNEL_SIZE][KERNEL_SIZE];
    uint8_t filter_ch1[KERNEL_SIZE][KERNEL_SIZE];
    int32_t output_ch0[OUT_HEIGHT][OUT_WIDTH];
    int32_t output_ch1[OUT_HEIGHT][OUT_WIDTH];

    // 生成输入矩阵和滤波器
    for (int i = 0; i < HEIGHT; i++)
        for (int j = 0; j < WIDTH; j++) {
            input_ch0[i][j] = rand8();
            input_ch1[i][j] = rand8();
        }

    for (int i = 0; i < KERNEL_SIZE; i++)
        for (int j = 0; j < KERNEL_SIZE; j++) {
            filter_ch0[i][j] = rand8();
            filter_ch1[i][j] = rand8();
        }

    // 卷积运算
    for (int i = 0; i < OUT_HEIGHT; i++)
        for (int j = 0; j < OUT_WIDTH; j++) {
            output_ch0[i][j] = conv2d(input_ch0, filter_ch0, i, j);
            output_ch1[i][j] = conv2d(input_ch1, filter_ch1, i, j);
        }

    // 写入 input_decimal.txt 和 input_binary.txt
    FILE *f_in_dec = fopen("input_decimal.txt", "w");
    FILE *f_in_bin = fopen("input_binary.txt", "w");
    for (int i = 0; i < HEIGHT; i++)
        for (int j = 0; j < WIDTH; j++) {
            fprintf(f_in_dec, "%d\n", input_ch0[i][j]);
            write_binary(f_in_bin, input_ch0[i][j], 8);
        }
    for (int i = 0; i < HEIGHT; i++)
        for (int j = 0; j < WIDTH; j++) {
            fprintf(f_in_dec, "%d\n", input_ch1[i][j]);
            write_binary(f_in_bin, input_ch1[i][j], 8);
        }
    fclose(f_in_dec);
    fclose(f_in_bin);

    // 写入 filter_decimal.txt 和 filter_binary.txt
    FILE *f_filt_dec = fopen("filter_decimal.txt", "w");
    FILE *f_filt_bin = fopen("filter_binary.txt", "w");
    for (int i = 0; i < KERNEL_SIZE; i++)
        for (int j = 0; j < KERNEL_SIZE; j++) {
            fprintf(f_filt_dec, "%d\n", filter_ch0[i][j]);
            write_binary(f_filt_bin, filter_ch0[i][j], 8);
        }
    for (int i = 0; i < KERNEL_SIZE; i++)
        for (int j = 0; j < KERNEL_SIZE; j++) {
            fprintf(f_filt_dec, "%d\n", filter_ch1[i][j]);
            write_binary(f_filt_bin, filter_ch1[i][j], 8);
        }
    fclose(f_filt_dec);
    fclose(f_filt_bin);

    // 写入 output_decimal.txt 和 output_binary.txt
    FILE *f_out_dec = fopen("output_decimal.txt", "w");
    FILE *f_out_bin = fopen("output_binary.txt", "w");
    for (int i = 0; i < OUT_HEIGHT; i++)
        for (int j = 0; j < OUT_WIDTH; j++) {
            fprintf(f_out_dec, "%d\n", output_ch0[i][j]);
            write_binary(f_out_bin, output_ch0[i][j], 20);
        }
    for (int i = 0; i < OUT_HEIGHT; i++)
        for (int j = 0; j < OUT_WIDTH; j++) {
            fprintf(f_out_dec, "%d\n", output_ch1[i][j]);
            write_binary(f_out_bin, output_ch1[i][j], 20);
        }
    fclose(f_out_dec);
    fclose(f_out_bin);

    // 写入 C 数组到 matrices.h
    FILE *f_h = fopen("matrices.h", "w");

    fprintf(f_h, "#ifndef MATRICES_H\n#define MATRICES_H\n\n");

    fprintf(f_h, "uint8_t input_ch0[%d][%d] = {\n", HEIGHT, WIDTH);
    for (int i = 0; i < HEIGHT; i++) {
        fprintf(f_h, "  {");
        for (int j = 0; j < WIDTH; j++) {
            fprintf(f_h, "%3d%s", input_ch0[i][j], j == WIDTH - 1 ? "" : ", ");
        }
        fprintf(f_h, "}%s\n", i == HEIGHT - 1 ? "" : ",");
    }
    fprintf(f_h, "};\n\n");

    fprintf(f_h, "uint8_t input_ch1[%d][%d] = {\n", HEIGHT, WIDTH);
    for (int i = 0; i < HEIGHT; i++) {
        fprintf(f_h, "  {");
        for (int j = 0; j < WIDTH; j++) {
            fprintf(f_h, "%3d%s", input_ch1[i][j], j == WIDTH - 1 ? "" : ", ");
        }
        fprintf(f_h, "}%s\n", i == HEIGHT - 1 ? "" : ",");
    }
    fprintf(f_h, "};\n\n");

    fprintf(f_h, "uint8_t filter_ch0[%d][%d] = {\n", KERNEL_SIZE, KERNEL_SIZE);
    for (int i = 0; i < KERNEL_SIZE; i++) {
        fprintf(f_h, "  {");
        for (int j = 0; j < KERNEL_SIZE; j++) {
            fprintf(f_h, "%3d%s", filter_ch0[i][j], j == KERNEL_SIZE - 1 ? "" : ", ");
        }
        fprintf(f_h, "}%s\n", i == KERNEL_SIZE - 1 ? "" : ",");
    }
    fprintf(f_h, "};\n\n");

    fprintf(f_h, "uint8_t filter_ch1[%d][%d] = {\n", KERNEL_SIZE, KERNEL_SIZE);
    for (int i = 0; i < KERNEL_SIZE; i++) {
        fprintf(f_h, "  {");
        for (int j = 0; j < KERNEL_SIZE; j++) {
            fprintf(f_h, "%3d%s", filter_ch1[i][j], j == KERNEL_SIZE - 1 ? "" : ", ");
        }
        fprintf(f_h, "}%s\n", i == KERNEL_SIZE - 1 ? "" : ",");
    }
    fprintf(f_h, "};\n\n");

    fprintf(f_h, "#endif // MATRICES_H\n");
    fclose(f_h);

    printf("✅ 所有文件生成完成！\n");
    return 0;
}
