"""
Script para fazer predições com modelo treinado
"""
import argparse
import numpy as np
from pathlib import Path
import sys

sys.path.append(str(Path(__file__).parent.parent))

from src.preprocessing.audio_processor import AudioProcessor
from src.features.feature_extractor import FeatureExtractor
from src.models.cough_classifier import CoughClassifier
import tensorflow as tf


def predict_audio(
    audio_path: str,
    model_path: str,
    feature_type: str = 'mel',
    class_names: list = None
):
    """
    Faz predição em um arquivo de áudio
    
    Args:
        audio_path: Caminho do áudio
        model_path: Caminho do modelo
        feature_type: Tipo de característica
        class_names: Nomes das classes (opcional)
    """
    # Processa áudio
    print(f"Processando áudio: {audio_path}")
    processor = AudioProcessor()
    audio = processor.process(audio_path)
    
    # Extrai características
    print("Extraindo características...")
    extractor = FeatureExtractor()
    
    if feature_type == 'mel':
        features = extractor.extract_mel_spectrogram(audio)
        features = np.expand_dims(features, axis=-1)
    elif feature_type == 'mfcc':
        features = extractor.extract_mfcc(audio)
        features = features.reshape(1, -1, 1)
    else:
        raise ValueError(f"Tipo de característica desconhecido: {feature_type}")
    
    # Adiciona dimensão de batch
    features = np.expand_dims(features, axis=0)
    
    # Carrega modelo
    print(f"Carregando modelo: {model_path}")
    model = tf.keras.models.load_model(model_path)
    
    # Faz predição
    print("Fazendo predição...")
    predictions = model.predict(features, verbose=0)
    
    # Mostra resultados
    predicted_class_idx = np.argmax(predictions[0])
    confidence = predictions[0][predicted_class_idx]
    
    if class_names is None:
        class_names = [f"Classe {i}" for i in range(len(predictions[0]))]
    
    print("\n" + "="*50)
    print("RESULTADOS DA PREDIÇÃO")
    print("="*50)
    print(f"\nClasse predita: {class_names[predicted_class_idx]}")
    print(f"Confiança: {confidence:.2%}")
    print("\nProbabilidades por classe:")
    for i, (class_name, prob) in enumerate(zip(class_names, predictions[0])):
        marker = " <-- PREDITO" if i == predicted_class_idx else ""
        print(f"  {class_name}: {prob:.2%}{marker}")
    print("="*50)
    
    return predictions, class_names[predicted_class_idx], confidence


def main():
    parser = argparse.ArgumentParser(description='Faz predição em áudio de tosse')
    parser.add_argument('--audio_path', type=str, required=True,
                       help='Caminho do arquivo de áudio')
    parser.add_argument('--model_path', type=str, required=True,
                       help='Caminho do modelo treinado')
    parser.add_argument('--feature_type', type=str, default='mel',
                       choices=['mel', 'mfcc'],
                       help='Tipo de característica')
    parser.add_argument('--classes', type=str, nargs='+',
                       default=None,
                       help='Nomes das classes (ex: Normal Bronquite Pneumonia)')
    
    args = parser.parse_args()
    
    predict_audio(
        audio_path=args.audio_path,
        model_path=args.model_path,
        feature_type=args.feature_type,
        class_names=args.classes
    )


if __name__ == '__main__':
    main()

