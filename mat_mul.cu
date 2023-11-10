#include <stdio.h>
#include <cuda_runtime.h>
#include <cublas_v2.h>
#include <math.h>
#include <stdlib.h>

#define MAX_FILE_NAME 64

/**
 * @brief scan the matrix from file
 *
 * @param n1
 * @param n2
 * @param matrix
 * @param file
 */
void get_matrix(int n1, int n2, float *matrix, FILE *file)
{
    for (int i = 0; i < n1; i++)
    {
        for (int j = 0; j < n2; j++)
        {
            fscanf(file, "%f ", matrix + i * n2 + j);
        }
    }
}

/**
 * @brief Get the inputs from given file
 *
 * @param M1
 * @param M2
 * @param n1
 * @param n2
 * @param n3
 */
void get_inputs(float **M1, float **M2, int *n1, int *n2, int *n3)
{
    char file_path[MAX_FILE_NAME];
    printf("input path to txt file:\n");
    scanf("%s", file_path);
    FILE *file = fopen(file_path, "r");
    fscanf(file, "%d %d %d\n", n1, n2, n3);

    *M1 = (float *)malloc((*n1) * (*n2) * sizeof(float));
    *M2 = (float *)malloc((*n2) * (*n3) * sizeof(float));

    get_matrix(*n1, *n2, *M1, file);
    get_matrix(*n2, *n3, *M2, file);
    fclose(file);
}

/**
 * @brief compare computed results with the real results (in low dimensions)
 *
 * @param Ans
 * @param A
 * @param B
 * @param n1
 * @param n2
 * @param n3
 */
void verify(float *Ans, float *A, float *B, int n1, int n2, int n3)
{
    for (int i = 0; i < n1; i++)
    {
        for (int j = 0; j < n3; j++)
        {
            float sum = 0;
            for (int k = 0; k < n2; k++)
            {
                sum += A[i * n2 + k] * B[k * n3 + j];
            }
            printf("%.2f ", sum);
        }
        printf("\n");
    }
    for (int i = 0; i < 120; i++)
    {
        printf("%.2f ", Ans[i]);
    }
}

int main()
{

    int m, n, k;
    float *A, *B, *C;

    get_inputs(&A, &B, &m, &n, &k);

    float *A_d, *B_d, *C_d;
    C = (float *)malloc(m * k * sizeof(float));
    cudaMalloc(&A_d, m * n * sizeof(float));
    cudaMalloc(&B_d, n * k * sizeof(float));
    cudaMalloc(&C_d, m * k * sizeof(float));

    cublasHandle_t handle;
    cublasCreate(&handle);

    cudaMemcpy(A_d, A, m * n * sizeof(float), cudaMemcpyHostToDevice);
    cudaMemcpy(B_d, B, n * k * sizeof(float), cudaMemcpyHostToDevice);

    float alpha = 1.0f;
    float beta = 0.0f;

    cublasSgemm(handle, CUBLAS_OP_N, CUBLAS_OP_N, m, m, n, &alpha, B_d, k, A_d, k, &beta, C_d, n);
    cudaMemcpy(C, C_d, m * k * sizeof(float), cudaMemcpyDeviceToHost);

    verify(C, A, B, m, n, k);

    cublasDestroy(handle);
    free(A);
    free(B);
    free(C);
    cudaFree(A_d);
    cudaFree(B_d);
    cudaFree(C_d);

    return 0;
}