"""
Script de treinamento do modelo de classificação de tosse
"""
import os
import argparse
import numpy as np
import pandas as pd
from pathlib import Path
import tensorflow as tf
from tensorflow import keras
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder
import sys

# Adiciona o diretório raiz ao path
sys.path.append(str(Path(__file__).parent.parent.parent))

from src.preprocessing.audio_processor import AudioProcessor
from src.features.feature_extractor import FeatureExtractor
from src.models.cough_classifier import CoughClassifier
import json


def load_data(data_dir: str, feature_type: str = 'mel'):
    """
    Carrega e processa dados de áudio
    
    Args:
        data_dir: Diretório com os dados
        feature_type: Tipo de característica a extrair
        
    Returns:
        X (features), y (labels)
    """
    data_dir = Path(data_dir)
    processor = AudioProcessor()
    extractor = FeatureExtractor()
    
    X = []
    y = []
    
    # Assumindo estrutura: data_dir/class_name/*.wav
    for class_dir in data_dir.iterdir():
        if not class_dir.is_dir():
            continue
        
        class_name = class_dir.name
        print(f"Processando classe: {class_name}")
        
        for audio_file in class_dir.glob("*.wav"):
            try:
                # Processa áudio
                audio = processor.process(audio_file)
                
                # Extrai características
                if feature_type == 'mel':
                    features = extractor.extract_mel_spectrogram(audio)
                    # Adiciona dimensão de canal para CNN
                    features = np.expand_dims(features, axis=-1)
                elif feature_type == 'mfcc':
                    features = extractor.extract_mfcc(audio)
                    # Para MFCC, pode precisar reshape
                    features = features.reshape(-1, 1)
                else:
                    raise ValueError(f"Tipo de característica desconhecido: {feature_type}")
                
                X.append(features)
                y.append(class_name)
                
            except Exception as e:
                print(f"Erro ao processar {audio_file}: {e}")
                continue
    
    return np.array(X), np.array(y)


def load_processed_data(processed_data_dir: str, feature_type: str = 'mel'):
    """
    Carrega dados pré-processados de arquivos .npy
    
    Args:
        processed_data_dir: Diretório com dados processados (.npy)
        feature_type: Tipo de característica ('mel' ou 'mfcc')
        
    Returns:
        Dados divididos e label_encoder
    """
    data_dir = Path(processed_data_dir)
    
    # Carrega características
    if feature_type == 'mel':
        X_train = np.load(data_dir / 'X_train_mel.npy')
        X_val = np.load(data_dir / 'X_val_mel.npy')
        X_test = np.load(data_dir / 'X_test_mel.npy')
    elif feature_type == 'mfcc':
        X_train = np.load(data_dir / 'X_train_mfcc.npy')
        X_val = np.load(data_dir / 'X_val_mfcc.npy')
        X_test = np.load(data_dir / 'X_test_mfcc.npy')
    else:
        raise ValueError(f"Tipo de característica desconhecido: {feature_type}")
    
    # Carrega labels
    y_train = np.load(data_dir / 'y_train.npy')
    y_val = np.load(data_dir / 'y_val.npy')
    y_test = np.load(data_dir / 'y_test.npy')
    
    # Carrega metadados
    metadata_path = data_dir / 'metadata.json'
    if metadata_path.exists():
        with open(metadata_path, 'r') as f:
            metadata = json.load(f)
        class_names = metadata['label_encoder_classes']
    else:
        # Se não houver metadata, assume classes padrão
        class_names = ['Bronchitis', 'Pneumonia']
    
    # Cria label encoder
    label_encoder = LabelEncoder()
    label_encoder.classes_ = np.array(class_names)
    
    # Converte labels para categorical
    y_train_cat = keras.utils.to_categorical(y_train, num_classes=len(class_names))
    y_val_cat = keras.utils.to_categorical(y_val, num_classes=len(class_names))
    y_test_cat = keras.utils.to_categorical(y_test, num_classes=len(class_names))
    
    # Adiciona dimensão de canal se necessário (para CNN)
    if len(X_train.shape) == 3:  # (samples, height, width)
        X_train = np.expand_dims(X_train, axis=-1)
        X_val = np.expand_dims(X_val, axis=-1)
        X_test = np.expand_dims(X_test, axis=-1)
    
    return (X_train, X_val, X_test, y_train_cat, y_val_cat, y_test_cat), label_encoder


def prepare_data(X, y, test_size=0.2, val_size=0.1):
    """
    Prepara dados para treinamento
    
    Args:
        X: Features
        y: Labels
        test_size: Proporção de teste
        val_size: Proporção de validação (do conjunto de treino)
        
    Returns:
        Dados divididos e codificados
    """
    # Codifica labels
    label_encoder = LabelEncoder()
    y_encoded = label_encoder.fit_transform(y)
    y_categorical = keras.utils.to_categorical(y_encoded)
    
    # Divide dados
    X_train, X_test, y_train, y_test = train_test_split(
        X, y_categorical, test_size=test_size, random_state=42, stratify=y_categorical
    )
    
    X_train, X_val, y_train, y_val = train_test_split(
        X_train, y_train, test_size=val_size, random_state=42, stratify=y_train
    )
    
    return (X_train, X_val, X_test, y_train, y_val, y_test), label_encoder


def train_model(
    data_dir: str,
    epochs: int = 50,
    batch_size: int = 32,
    feature_type: str = 'mel',
    model_type: str = 'cnn',
    output_dir: str = 'models',
    use_processed: bool = False
):
    """
    Treina o modelo
    
    Args:
        data_dir: Diretório com dados ou dados processados
        epochs: Número de épocas
        batch_size: Tamanho do batch
        feature_type: Tipo de característica
        model_type: Tipo de modelo
        output_dir: Diretório para salvar modelos
        use_processed: Se True, carrega dados pré-processados (.npy)
    """
    if use_processed:
        print("Carregando dados pré-processados...")
        (X_train, X_val, X_test, y_train, y_val, y_test), label_encoder = load_processed_data(
            data_dir, feature_type
        )
    else:
        print("Carregando e processando dados...")
        X, y = load_data(data_dir, feature_type)
        
        print(f"Shape dos dados: {X.shape}")
        print(f"Classes: {np.unique(y)}")
        
        # Prepara dados
        (X_train, X_val, X_test, y_train, y_val, y_test), label_encoder = prepare_data(X, y)
    
    print(f"Treino: {X_train.shape}, Validação: {X_val.shape}, Teste: {X_test.shape}")
    
    # Determina input_shape
    input_shape = X_train.shape[1:]
    
    # Cria modelo
    print("Construindo modelo...")
    classifier = CoughClassifier(
        input_shape=input_shape,
        num_classes=len(label_encoder.classes_),
        model_type=model_type
    )
    model = classifier.get_model()
    
    model.summary()
    
    # Callbacks
    output_path = Path(output_dir)
    output_path.mkdir(parents=True, exist_ok=True)
    
    callbacks = [
        keras.callbacks.ModelCheckpoint(
            str(output_path / 'checkpoints' / 'best_model.h5'),
            monitor='val_accuracy',
            save_best_only=True,
            mode='max'
        ),
        keras.callbacks.EarlyStopping(
            monitor='val_loss',
            patience=10,
            restore_best_weights=True
        ),
        keras.callbacks.ReduceLROnPlateau(
            monitor='val_loss',
            factor=0.5,
            patience=5,
            min_lr=1e-7
        )
    ]
    
    # Treina modelo
    print("Treinando modelo...")
    history = model.fit(
        X_train, y_train,
        validation_data=(X_val, y_val),
        epochs=epochs,
        batch_size=batch_size,
        callbacks=callbacks,
        verbose=1
    )
    
    # Avalia no conjunto de teste
    print("\nAvaliando no conjunto de teste...")
    test_loss, test_acc, _ = model.evaluate(X_test, y_test, verbose=0)
    print(f"Teste - Loss: {test_loss:.4f}, Accuracy: {test_acc:.4f}")
    
    # Salva modelo final
    final_model_path = output_path / 'best_model.h5'
    classifier.save_model(str(final_model_path))
    print(f"\nModelo salvo em: {final_model_path}")
    
    # Converte para TFLite
    print("\nConvertendo para TensorFlow Lite...")
    tflite_path = output_path / 'tflite' / 'cough_classifier.tflite'
    tflite_path.parent.mkdir(parents=True, exist_ok=True)
    classifier.convert_to_tflite(str(tflite_path), quantization='float16')
    
    return model, history, label_encoder


def main():
    parser = argparse.ArgumentParser(description='Treina modelo de classificação de tosse')
    parser.add_argument('--data_dir', type=str, required=True,
                       help='Diretório com dados organizados por classe')
    parser.add_argument('--epochs', type=int, default=50,
                       help='Número de épocas')
    parser.add_argument('--batch_size', type=int, default=32,
                       help='Tamanho do batch')
    parser.add_argument('--feature_type', type=str, default='mel',
                       choices=['mel', 'mfcc'],
                       help='Tipo de característica')
    parser.add_argument('--model_type', type=str, default='cnn',
                       choices=['cnn', 'mobilenet'],
                       help='Tipo de modelo')
    parser.add_argument('--output_dir', type=str, default='models',
                       help='Diretório para salvar modelos')
    parser.add_argument('--use_processed', action='store_true',
                       help='Usar dados pré-processados (.npy)')
    
    args = parser.parse_args()
    
    train_model(
        data_dir=args.data_dir,
        epochs=args.epochs,
        batch_size=args.batch_size,
        feature_type=args.feature_type,
        model_type=args.model_type,
        output_dir=args.output_dir,
        use_processed=args.use_processed
    )


if __name__ == '__main__':
    main()

