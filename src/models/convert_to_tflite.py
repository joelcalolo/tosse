"""
Script para converter modelo treinado para TensorFlow Lite
"""
import argparse
from pathlib import Path
import sys

sys.path.append(str(Path(__file__).parent.parent.parent))

from src.models.cough_classifier import CoughClassifier
import tensorflow as tf


def convert_model(
    model_path: str,
    output_path: str,
    quantization: str = 'float16'
):
    """
    Converte modelo Keras para TensorFlow Lite
    
    Args:
        model_path: Caminho do modelo Keras (.h5)
        output_path: Caminho para salvar modelo TFLite
        quantization: Tipo de quantização
    """
    print(f"Carregando modelo de: {model_path}")
    
    # Carrega modelo
    model = tf.keras.models.load_model(model_path)
    
    # Cria classificador temporário para usar método de conversão
    input_shape = model.input_shape[1:]
    num_classes = model.output_shape[-1]
    
    classifier = CoughClassifier(input_shape, num_classes)
    classifier.model = model
    
    # Converte para TFLite
    print(f"Convertendo para TensorFlow Lite ({quantization})...")
    classifier.convert_to_tflite(output_path, quantization)
    
    print(f"Modelo TFLite salvo em: {output_path}")


def main():
    parser = argparse.ArgumentParser(description='Converte modelo para TensorFlow Lite')
    parser.add_argument('--model_path', type=str, required=True,
                       help='Caminho do modelo Keras (.h5)')
    parser.add_argument('--output_path', type=str, required=True,
                       help='Caminho para salvar modelo TFLite')
    parser.add_argument('--quantization', type=str, default='float16',
                       choices=['float16', 'int8', 'none'],
                       help='Tipo de quantização')
    
    args = parser.parse_args()
    
    convert_model(
        model_path=args.model_path,
        output_path=args.output_path,
        quantization=args.quantization
    )


if __name__ == '__main__':
    main()

