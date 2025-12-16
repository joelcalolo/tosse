"""
Extrator de características de áudio (MFCC, Espectrogramas, etc.)
"""
import numpy as np
import librosa
from typing import Tuple, Optional


class FeatureExtractor:
    """
    Classe para extração de características de áudio
    """
    
    def __init__(
        self,
        sample_rate: int = 16000,
        n_mfcc: int = 13,
        n_mels: int = 128,
        n_fft: int = 2048,
        hop_length: int = 512
    ):
        """
        Inicializa o extrator de características
        
        Args:
            sample_rate: Taxa de amostragem
            n_mfcc: Número de coeficientes MFCC
            n_mels: Número de filtros Mel
            n_fft: Tamanho da FFT
            hop_length: Tamanho do hop para análise
        """
        self.sample_rate = sample_rate
        self.n_mfcc = n_mfcc
        self.n_mels = n_mels
        self.n_fft = n_fft
        self.hop_length = hop_length
    
    def extract_mfcc(
        self,
        audio: np.ndarray,
        delta: bool = True,
        delta2: bool = True
    ) -> np.ndarray:
        """
        Extrai coeficientes MFCC (Mel-Frequency Cepstral Coefficients)
        
        Args:
            audio: Array de áudio
            delta: Se deve incluir primeira derivada (delta)
            delta2: Se deve incluir segunda derivada (delta-delta)
            
        Returns:
            Array de características MFCC
        """
        # MFCC base
        mfccs = librosa.feature.mfcc(
            y=audio,
            sr=self.sample_rate,
            n_mfcc=self.n_mfcc,
            n_fft=self.n_fft,
            hop_length=self.hop_length
        )
        
        features = [mfccs]
        
        # Primeira derivada (delta)
        if delta:
            mfcc_delta = librosa.feature.delta(mfccs)
            features.append(mfcc_delta)
        
        # Segunda derivada (delta-delta)
        if delta2:
            mfcc_delta2 = librosa.feature.delta(mfccs, order=2)
            features.append(mfcc_delta2)
        
        # Concatena todas as características
        mfcc_features = np.concatenate(features, axis=0)
        
        # Média ao longo do tempo (pode também usar outras estatísticas)
        return np.mean(mfcc_features, axis=1)
    
    def extract_mel_spectrogram(self, audio: np.ndarray) -> np.ndarray:
        """
        Extrai espectrograma Mel (Log-Mel)
        
        Args:
            audio: Array de áudio
            
        Returns:
            Espectrograma Mel em escala logarítmica
        """
        mel_spec = librosa.feature.melspectrogram(
            y=audio,
            sr=self.sample_rate,
            n_mels=self.n_mels,
            n_fft=self.n_fft,
            hop_length=self.hop_length
        )
        
        # Converte para escala logarítmica (dB)
        log_mel_spec = librosa.power_to_db(mel_spec, ref=np.max)
        
        return log_mel_spec
    
    def extract_zcr(self, audio: np.ndarray) -> float:
        """
        Extrai Zero Crossing Rate
        
        Args:
            audio: Array de áudio
            
        Returns:
            Taxa de cruzamento por zero
        """
        zcr = librosa.feature.zero_crossing_rate(audio)[0]
        return np.mean(zcr)
    
    def extract_chroma(self, audio: np.ndarray) -> np.ndarray:
        """
        Extrai características Chroma
        
        Args:
            audio: Array de áudio
            
        Returns:
            Características Chroma
        """
        chroma = librosa.feature.chroma_stft(
            y=audio,
            sr=self.sample_rate,
            n_fft=self.n_fft,
            hop_length=self.hop_length
        )
        return np.mean(chroma, axis=1)
    
    def extract_all_features(
        self,
        audio: np.ndarray,
        include_mfcc: bool = True,
        include_mel: bool = True,
        include_zcr: bool = True,
        include_chroma: bool = False
    ) -> dict:
        """
        Extrai todas as características configuradas
        
        Args:
            audio: Array de áudio
            include_mfcc: Incluir MFCC
            include_mel: Incluir espectrograma Mel
            include_zcr: Incluir ZCR
            include_chroma: Incluir Chroma
            
        Returns:
            Dicionário com todas as características extraídas
        """
        features = {}
        
        if include_mfcc:
            features['mfcc'] = self.extract_mfcc(audio)
        
        if include_mel:
            features['mel_spectrogram'] = self.extract_mel_spectrogram(audio)
        
        if include_zcr:
            features['zcr'] = self.extract_zcr(audio)
        
        if include_chroma:
            features['chroma'] = self.extract_chroma(audio)
        
        return features
    
    def extract_features_for_model(
        self,
        audio: np.ndarray,
        feature_type: str = 'mfcc'
    ) -> np.ndarray:
        """
        Extrai características no formato adequado para o modelo
        
        Args:
            audio: Array de áudio
            feature_type: Tipo de característica ('mfcc', 'mel', 'combined')
            
        Returns:
            Array de características pronto para o modelo
        """
        if feature_type == 'mfcc':
            return self.extract_mfcc(audio)
        
        elif feature_type == 'mel':
            mel_spec = self.extract_mel_spectrogram(audio)
            # Redimensiona para formato adequado (pode precisar ajuste)
            return mel_spec
        
        elif feature_type == 'combined':
            # Combina múltiplas características
            mfcc = self.extract_mfcc(audio)
            zcr = np.array([self.extract_zcr(audio)])
            return np.concatenate([mfcc, zcr])
        
        else:
            raise ValueError(f"Tipo de característica desconhecido: {feature_type}")
    
    def extract_for_mobilenet(self, audio: np.ndarray) -> np.ndarray:
        """
        Extrai características no formato adequado para MobileNetV2
        
        Args:
            audio: Array de áudio
            
        Returns:
            Espectrograma Mel no formato (height, width, 1) para MobileNetV2
        """
        # Extrai espectrograma Mel
        mel_spec = self.extract_mel_spectrogram(audio)
        
        # Adiciona dimensão de canal para CNN (height, width, channels)
        mel_spec = np.expand_dims(mel_spec, axis=-1)
        
        return mel_spec

