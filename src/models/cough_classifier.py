"""
Modelo de classificação de tosse usando CNN
"""
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers
from typing import Tuple, Optional


class CoughClassifier:
    """
    Classificador de tosse usando CNN para detectar pneumonia e bronquite
    """
    
    def __init__(
        self,
        input_shape: Tuple[int, ...],
        num_classes: int = 3,  # Normal, Bronquite, Pneumonia
        model_type: str = 'cnn'
    ):
        """
        Inicializa o classificador
        
        Args:
            input_shape: Formato de entrada (ex: (128, 128, 1) para espectrogramas)
            num_classes: Número de classes de saída
            model_type: Tipo de modelo ('cnn', 'mobilenet')
        """
        self.input_shape = input_shape
        self.num_classes = num_classes
        self.model_type = model_type
        self.model = None
    
    def build_cnn_model(self) -> keras.Model:
        """
        Constrói modelo CNN customizado
        
        Returns:
            Modelo Keras compilado
        """
        model = keras.Sequential([
            # Primeira camada convolucional
            layers.Conv2D(32, (3, 3), activation='relu', input_shape=self.input_shape),
            layers.BatchNormalization(),
            layers.MaxPooling2D((2, 2)),
            layers.Dropout(0.25),
            
            # Segunda camada convolucional
            layers.Conv2D(64, (3, 3), activation='relu'),
            layers.BatchNormalization(),
            layers.MaxPooling2D((2, 2)),
            layers.Dropout(0.25),
            
            # Terceira camada convolucional
            layers.Conv2D(128, (3, 3), activation='relu'),
            layers.BatchNormalization(),
            layers.MaxPooling2D((2, 2)),
            layers.Dropout(0.25),
            
            # Flatten e camadas densas
            layers.GlobalAveragePooling2D(),
            layers.Dense(128, activation='relu'),
            layers.Dropout(0.5),
            layers.Dense(64, activation='relu'),
            layers.Dropout(0.5),
            
            # Camada de saída
            layers.Dense(self.num_classes, activation='softmax')
        ])
        
        return model
    
    def build_mobilenet_model(self) -> keras.Model:
        """
        Constrói modelo baseado em MobileNetV2 (otimizado para mobile)
        
        Returns:
            Modelo Keras compilado
        """
        # Base MobileNetV2
        base_model = keras.applications.MobileNetV2(
            input_shape=self.input_shape,
            include_top=False,
            weights=None  # Sem pesos pré-treinados para áudio
        )
        
        # Adiciona camadas customizadas
        model = keras.Sequential([
            base_model,
            layers.GlobalAveragePooling2D(),
            layers.Dense(128, activation='relu'),
            layers.Dropout(0.5),
            layers.Dense(self.num_classes, activation='softmax')
        ])
        
        return model
    
    def build_model(self) -> keras.Model:
        """
        Constrói o modelo baseado no tipo especificado
        
        Returns:
            Modelo Keras compilado
        """
        if self.model_type == 'cnn':
            self.model = self.build_cnn_model()
        elif self.model_type == 'mobilenet':
            self.model = self.build_mobilenet_model()
        else:
            raise ValueError(f"Tipo de modelo desconhecido: {self.model_type}")
        
        # Compila o modelo
        self.model.compile(
            optimizer=keras.optimizers.Adam(learning_rate=0.001),
            loss='categorical_crossentropy',
            metrics=['accuracy', 'top_k_categorical_accuracy']
        )
        
        return self.model
    
    def get_model(self) -> keras.Model:
        """
        Retorna o modelo (constrói se necessário)
        
        Returns:
            Modelo Keras
        """
        if self.model is None:
            self.build_model()
        return self.model
    
    def save_model(self, filepath: str):
        """
        Salva o modelo
        
        Args:
            filepath: Caminho para salvar
        """
        if self.model is None:
            raise ValueError("Modelo ainda não foi construído")
        self.model.save(filepath)
    
    def load_model(self, filepath: str):
        """
        Carrega modelo salvo
        
        Args:
            filepath: Caminho do modelo
        """
        self.model = keras.models.load_model(filepath)
    
    def convert_to_tflite(
        self,
        output_path: str,
        quantization: str = 'float16'
    ):
        """
        Converte modelo para TensorFlow Lite (otimizado para mobile)
        
        Args:
            output_path: Caminho para salvar modelo TFLite
            quantization: Tipo de quantização ('float16', 'int8', 'none')
        """
        if self.model is None:
            raise ValueError("Modelo ainda não foi construído")
        
        converter = tf.lite.TFLiteConverter.from_keras_model(self.model)
        
        if quantization == 'float16':
            converter.optimizations = [tf.lite.Optimize.DEFAULT]
            converter.target_spec.supported_types = [tf.float16]
        elif quantization == 'int8':
            # Para INT8, precisa de dataset representativo
            converter.optimizations = [tf.lite.Optimize.DEFAULT]
            converter.target_spec.supported_ops = [tf.lite.OpsSet.TFLITE_BUILTINS_INT8]
            converter.inference_input_type = tf.int8
            converter.inference_output_type = tf.int8
        
        tflite_model = converter.convert()
        
        with open(output_path, 'wb') as f:
            f.write(tflite_model)
        
        print(f"Modelo TFLite salvo em: {output_path}")

