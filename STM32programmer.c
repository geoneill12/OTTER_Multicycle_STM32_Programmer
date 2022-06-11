
#include "main.h"
#include "otter_memory.h"
#include <stdio.h>
#include <stdlib.h>
#define	CS			0x100
#define ENA			0x200
#define LED_on		0x20
#define LED_off		0x0
#define	DELAY		1		// set to 1 for 50MHz OTTER; 7,300 gives 1ms delay
UART_HandleTypeDef huart2;
void SystemClock_Config(void);
static void MX_GPIO_Init(void);
static void MX_USART2_UART_Init(void);
void progDelay(){
	for (int i=0; i<DELAY; i++){}
}

int main(void){

  HAL_Init();
  SystemClock_Config();
  MX_GPIO_Init();
  MX_USART2_UART_Init();

  RCC->AHB2ENR |= (RCC_AHB2ENR_GPIOAEN | RCC_AHB2ENR_GPIOCEN);
  GPIOA->MODER &= ~(GPIO_MODER_MODE5);
  GPIOA->MODER |= (GPIO_MODER_MODE5_0);
  GPIOA->ODR &= 0x0;
  GPIOC->MODER &= 0x0;
  GPIOC->MODER |= 0x55555555;
  GPIOC->ODR &= 0x0;

  /********** Program OTTER **********/
  uint32_t prog_len = sizeof(otter_memory) / sizeof(otter_memory[0]);
  GPIOA->ODR |= LED_on;
  GPIOC->ODR |= CS;
  progDelay();
  for(int i=0; i<prog_len; i++){

	  GPIOC->ODR &= 0xF00;
	  GPIOC->ODR |= (otter_memory[i] & 0xFF);
	  progDelay();
	  GPIOC->ODR |= ENA;
	  progDelay();
	  GPIOC->ODR &= ~ENA;
	  progDelay();

	  GPIOC->ODR &= 0xF00;
	  GPIOC->ODR |= ((otter_memory[i] >> 8) & 0xFF);
	  progDelay();
	  GPIOC->ODR |= ENA;
	  progDelay();
	  GPIOC->ODR &= ~ENA;
	  progDelay();

	  GPIOC->ODR &= 0xF00;
	  GPIOC->ODR |= ((otter_memory[i] >> 16) & 0xFF);
	  progDelay();
	  GPIOC->ODR |= ENA;
	  progDelay();
	  GPIOC->ODR &= ~ENA;
	  progDelay();

	  GPIOC->ODR &= 0xF00;
	  GPIOC->ODR |= ((otter_memory[i] >> 24) & 0xFF);
	  progDelay();
	  GPIOC->ODR |= ENA;
	  progDelay();
	  GPIOC->ODR &= ~ENA;
	  progDelay();

  }
  GPIOC->ODR &= 0x0;
  GPIOA->ODR &= LED_off;
  /***********************************/

  while(1){}

}

/****************************************************************************************************************************************/


void SystemClock_Config(void){
  RCC_OscInitTypeDef RCC_OscInitStruct = {0};
  RCC_ClkInitTypeDef RCC_ClkInitStruct = {0};

  if (HAL_PWREx_ControlVoltageScaling(PWR_REGULATOR_VOLTAGE_SCALE1) != HAL_OK){
    Error_Handler();
  }

  RCC_OscInitStruct.OscillatorType = RCC_OSCILLATORTYPE_HSI;
  RCC_OscInitStruct.HSIState = RCC_HSI_ON;
  RCC_OscInitStruct.HSICalibrationValue = RCC_HSICALIBRATION_DEFAULT;
  RCC_OscInitStruct.PLL.PLLState = RCC_PLL_ON;
  RCC_OscInitStruct.PLL.PLLSource = RCC_PLLSOURCE_HSI;
  RCC_OscInitStruct.PLL.PLLM = 1;
  RCC_OscInitStruct.PLL.PLLN = 10;
  RCC_OscInitStruct.PLL.PLLP = RCC_PLLP_DIV7;
  RCC_OscInitStruct.PLL.PLLQ = RCC_PLLQ_DIV2;
  RCC_OscInitStruct.PLL.PLLR = RCC_PLLR_DIV2;
  if (HAL_RCC_OscConfig(&RCC_OscInitStruct) != HAL_OK){
    Error_Handler();
  }

  RCC_ClkInitStruct.ClockType = RCC_CLOCKTYPE_HCLK|RCC_CLOCKTYPE_SYSCLK
                              |RCC_CLOCKTYPE_PCLK1|RCC_CLOCKTYPE_PCLK2;
  RCC_ClkInitStruct.SYSCLKSource = RCC_SYSCLKSOURCE_PLLCLK;
  RCC_ClkInitStruct.AHBCLKDivider = RCC_SYSCLK_DIV1;
  RCC_ClkInitStruct.APB1CLKDivider = RCC_HCLK_DIV1;
  RCC_ClkInitStruct.APB2CLKDivider = RCC_HCLK_DIV1;

  if (HAL_RCC_ClockConfig(&RCC_ClkInitStruct, FLASH_LATENCY_4) != HAL_OK){
    Error_Handler();
  }
}

static void MX_USART2_UART_Init(void){

  huart2.Instance = USART2;
  huart2.Init.BaudRate = 115200;
  huart2.Init.WordLength = UART_WORDLENGTH_8B;
  huart2.Init.StopBits = UART_STOPBITS_1;
  huart2.Init.Parity = UART_PARITY_NONE;
  huart2.Init.Mode = UART_MODE_TX_RX;
  huart2.Init.HwFlowCtl = UART_HWCONTROL_NONE;
  huart2.Init.OverSampling = UART_OVERSAMPLING_16;
  huart2.Init.OneBitSampling = UART_ONE_BIT_SAMPLE_DISABLE;
  huart2.AdvancedInit.AdvFeatureInit = UART_ADVFEATURE_NO_INIT;
  if (HAL_UART_Init(&huart2) != HAL_OK){
    Error_Handler();
  }
}

static void MX_GPIO_Init(void){
  GPIO_InitTypeDef GPIO_InitStruct = {0};

  __HAL_RCC_GPIOC_CLK_ENABLE();
  __HAL_RCC_GPIOH_CLK_ENABLE();
  __HAL_RCC_GPIOA_CLK_ENABLE();
  __HAL_RCC_GPIOB_CLK_ENABLE();

  HAL_GPIO_WritePin(LD2_GPIO_Port, LD2_Pin, GPIO_PIN_RESET);

  GPIO_InitStruct.Pin = B1_Pin;
  GPIO_InitStruct.Mode = GPIO_MODE_IT_FALLING;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  HAL_GPIO_Init(B1_GPIO_Port, &GPIO_InitStruct);

  GPIO_InitStruct.Pin = LD2_Pin;
  GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
  HAL_GPIO_Init(LD2_GPIO_Port, &GPIO_InitStruct);

}

void Error_Handler(void){

  __disable_irq();
  while (1){
  }
}

#ifdef  USE_FULL_ASSERT

void assert_failed(uint8_t *file, uint32_t line){
}
#endif
