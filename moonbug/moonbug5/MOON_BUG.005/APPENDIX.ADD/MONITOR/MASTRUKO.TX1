Д. Мастрюков

Алгоритмы сжатия информации

Часть 7. Сжатие графической информации

В статье описывается алгоритм сжатия графической информации JPEG и
приводится пример программы на языке С, реализующей этот алгоритм.
Листинг

/*-------------------------------------------------------------------
   Алгоритм сжатия графических образов JPEG.
   Демонстрационная программа.
*/

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

typedef unsigned long ulong;
typedef unsigned char uchar;

/*-------------------------------------------------------------------
   Эти параметры определяют размеры сжимаемой картинки и блока ДКП
*/

#define ROWS            200
#define COLS            320
#define N               8

/*-------------------------------------------------------------------
  Округление до ближайшего целого
*/
#define ROUND( a )      ( ( (a) < 0 ) ? (int) ( (a) - 0.5 ) : \
                                                  (int) ( (a) + 0.5 ) )

/*-------------------------------------------------------------------
 * Глобальные переменные
*/

uchar PixelStrip[ N ][ COLS ];
double C[ N ][ N ];
double Ct[ N ][ N ];
int InputRunLength;
int OutputRunLength;
int Quantum[ N ][ N ];

struct zigzag
{
    int row;
    int col;
}
ZigZag[ N * N ] =
{
    {0, 0},
    {0, 1}, {1, 0},
    {2, 0}, {1, 1}, {0, 2},
    {0, 3}, {1, 2}, {2, 1}, {3, 0},
    {4, 0}, {3, 1}, {2, 2}, {1, 3}, {0, 4},
    {0, 5}, {1, 4}, {2, 3}, {3, 2}, {4, 1}, {5, 0},
    {6, 0}, {5, 1}, {4, 2}, {3, 3}, {2, 4}, {1, 5}, {0, 6},
    {0, 7}, {1, 6}, {2, 5}, {3, 4}, {4, 3}, {5, 2}, {6, 1}, {7, 0},
    {7, 1}, {6, 2}, {5, 3}, {4, 4}, {3, 5}, {2, 6}, {1, 7},
    {2, 7}, {3, 6}, {4, 5}, {5, 4}, {6, 3}, {7, 2},
    {7, 3}, {6, 4}, {5, 5}, {4, 6}, {3, 7},
    {4, 7}, {5, 6}, {6, 5}, {7, 4},
    {7, 5}, {6, 6}, {5, 7},
    {6, 7}, {7, 6},
    {7, 7}
};

/*-------------------------------------------------------------------
   Инициализация матрицы КП, ее транспонированного вида и матрицы
   масштабирования.
*/

void Initialize( int quality )
{
    int i;
    int j;
    double pi = atan( 1.0 ) * 4.0;

    for ( i = 0 ; i < N ; i++ )
        for ( j = 0 ; j < N ; j++ )
            Quantum[i][j] = 1 + ( 1 + i + j ) * quality;

    OutputRunLength = 0;
    InputRunLength = 0;

    for ( j = 0 ; j < N ; j++ )
    {
        C[0][j] = 1.0 / sqrt((double) N);
        Ct[j][0] = C[0][j];
    }

    for ( i = 1 ; i < N ; i++ )
    {
        for ( j = 0 ; j < N ; j++ )
        {
            C[i][j] = sqrt(2.0/N) * cos(pi*(2*j+1)*i/(2.0*N));
            Ct[j][i] = C[i][j];
        }
    }
}

/*-------------------------------------------------------------------
   Процедура чтения N строк из 8-битового файла изображения.
   Затем они обрабатываются ДКП поблочно
*/
void ReadPixelStrip( FILE *input, uchar strip[N][COLS] )
{
    int row;
    int col;
    int c;

    for ( row = 0 ; row < N ; row++ )
        for ( col = 0 ; col < COLS ; col++ )
        {
           c = getc( input );
           strip[ row ][ col ] = (uchar) c;
        }
}

/*-------------------------------------------------------------------
   Чтение кода из сжатого файла
*/

int InputCode( BFILE *if )
{
    int bit_count;
    int result;

    if ( InputRunLength > 0 )
    {
        InputRunLength--;
        return( 0 );
    }

    bit_count = (int) InputBits( if, 2 );

    if ( bit_count == 0 )
    {
        InputRunLength = (int) InputBits( if, 4 );
        return( 0 );
    }

    if ( bit_count == 1 )
        bit_count = (int) InputBits( if, 1 ) + 1;
    else
        bit_count = (int) InputBits( if, 2 ) + ( bit_count << 2 ) - 5;

    result = (int) InputBits( if, bit_count );

    if ( result & ( 1 << ( bit_count - 1 ) ) )
        return( result );

    return ( result - ( 1 << bit_count ) + 1 );
}

/*-------------------------------------------------------------------
   Чтение блока ДКП из сжатого файла
*/

void ReadDCTData( BFILE *if, int input_data[N][N] )
{
    int i;
    int row;
    int col;

    for ( i = 0 ; i < ( N * N ) ; i++ )
    {
        row = ZigZag[ i ].row;
        col = ZigZag[ i ].col;
        input_data[ row ][ col ] = InputCode( if ) * Quantum[ row ][ col ];
    }
}

/*-------------------------------------------------------------------
   Выдача кода в сжатый файл
*/

void OutputCode( BFILE *of, int code )
{
    int top_of_range;
    int abs_code;
    int bit_count;

    if ( code == 0 )
    {
        OutputRunLength++;
        return;
    }
    if ( OutputRunLength != 0 )
    {
        while ( OutputRunLength > 0 )
        {
            OutputBits( of, 0L, 2 );
            if ( OutputRunLength <= 16 )
            {
                OutputBits( of, (ulong) ( OutputRunLength - 1 ), 4 );
                OutputRunLength = 0;
            }
            else
            {
                OutputBits( of, 15L, 4 );
                OutputRunLength -= 16;
            }
        }
    }
    if ( code < 0 )
        abs_code = -code;
    else
        abs_code = code;
    top_of_range = 1;
    bit_count = 1;
    while ( abs_code > top_of_range )
    {
        bit_count++;
        top_of_range = ( ( top_of_range + 1 ) * 2 ) - 1;
    }
    if ( bit_count < 3 )
        OutputBits( of, (ulong) ( bit_count + 1 ), 3 );
    else
        OutputBits( of, (ulong) ( bit_count + 5 ), 4 );
    if ( code > 0 )
        OutputBits( of, (ulong) code, bit_count );
    else
        OutputBits( of, (ulong) ( code + top_of_range ), bit_count );
}

/*-------------------------------------------------------------------
   Выдача обработанного блока ДКП в сжатый файл
*/

void WriteDCTData( BFILE *of, int output_data[N][N] )
{
    int i;
    int row;
    int col;
    double result;

    for ( i = 0 ; i < ( N * N ) ; i++ )
    {
        row = ZigZag[i].row;
        col = ZigZag[i].col;
        result = output_data[row][col] / Quantum[row][col];
        OutputCode( of, ROUND( result ) );
    }
}

/*-------------------------------------------------------------------
   Запись N строк в раскодированный файл
*/

void WritePixelStrip( FILE *output, uchar strip[N][COLS] )
{
    int row;
    int col;

    for ( row = 0 ; row < N ; row++ )
        for ( col = 0 ; col < COLS ; col++ )
           putc( strip[row][col], output );
}

/*-------------------------------------------------------------------
   Процедура, реализующая ДКП через перемножение матриц
       ДКП = КП х точки х КПт
*/

void ForwardDCT( uchar *input[N], int output[N][N] )
{
    double temp[N][N];
    double temp1;
    int i;
    int j;
    int k;

    for ( i = 0 ; i < N ; i++ )
    {
        for ( j = 0 ; j < N ; j++ )
        {
            temp[i][j] = 0.0;
            for ( k = 0 ; k < N ; k++ )
                 temp[i][j] += ( (int) input[i][k] - 128 ) * Ct[k][j];
        }
    }

    for ( i = 0 ; i < N ; i++ )
    {
        for ( j = 0 ; j < N ; j++ )
        {
            temp1 = 0.0;
            for ( k = 0 ; k < N ; k++ )
                temp1 += C[i][k] * temp[k][j];
            output[i][j] = ROUND( temp1 );
        }
    }
}

/*-------------------------------------------------------------------
   Процедура, реализующая ОДКП через перемножение матриц
      Точки = КП * ДКП * КПт
*/

void InverseDCT( int input[N][N], uchar *output[N] )
{
    double temp[N][N];
    double temp1;
    int i;
    int j;
    int k;

    for ( i = 0 ; i < N ; i++ )
    {
        for ( j = 0 ; j < N ; j++ )
        {
            temp[i][j] = 0.0;
            for ( k = 0 ; k < N ; k++ )
                temp[i][j] += input[i][k] * C[k][j];
        }
    }

    for ( i = 0 ; i < N ; i++ )
    {
        for ( j = 0 ; j < N ; j++ )
        {
            temp1 = 0.0;
            for ( k = 0 ; k < N ; k++ )
                temp1 += Ct[i][k] * temp[k][j];
            temp1 += 128.0;
            if ( temp1 < 0 )
                output[i][j] = 0;
            else if ( temp1 > 255 )
                output[i][j] = 255;
            else
                output[i][j] = (uchar) ROUND( temp1 );
        }
    }
}

/*-------------------------------------------------------------------
   Сжатие 8-битового графического файла
*/

void CompressFile( FILE *input, BFILE *output, int quality )
{
    int row;
    int col;
    int i;
    uchar *input_array[N];
    int output_array[N][N];

    if ( quality < 0 || quality > 50 )
       return;
    Initialize( quality );
    OutputBits( output, (ulong) quality, 8 );
    for ( row = 0 ; row < ROWS ; row += N )
    {
        ReadPixelStrip( input, PixelStrip );
        for ( col = 0 ; col < COLS ; col += N )
        {
            for ( i = 0 ; i < N ; i++ )
                input_array[i] = PixelStrip[i] + col;
            ForwardDCT( input_array, output_array );
            WriteDCTData( output, output_array );
        }
    }
    OutputCode( output, 1 );
}

/*-------------------------------------------------------------------
   Декомпрессия 8-битового графического файла
*/

void ExpandFile( BFILE *input, FILE *output )
{
    int row, col, i;
    int quality;
    int input_array[N][N];
    uchar *output_array[ N ];

    quality = (int) InputBits( input, 8 );
    Initialize( quality );
    for ( row = 0 ; row < ROWS ; row += N )
    {
        for ( col = 0 ; col < COLS ; col += N )
        {
            for ( i = 0 ; i < N ; i++ )
                output_array[i] = PixelStrip[i] + col;
            ReadDCTData( input, input_array );
            InverseDCT( input_array, output_array );
        }
        WritePixelStrip( output, PixelStrip );
    }
}

/*------------------------------ Конец демонстрационной программы ---*/

