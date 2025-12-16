"""
Processador de áudio para normalização, remoção de ruído e padronização
"""
import numpy as np
import librosa
import soundfile as sf
import noisereduce as nr
from pathlib import Path
from typing import Union, Tuple
from scipy import signal


class AudioProcessor:
    """
    Classe para pré-processamento de áudios de tosse
    """
    
    def __init__(
        self,
        sample_rate: int = 16000,
        target_duration: float = 3.0,
        normalize: bool = True,
        reduce_noise: bool = True,
        use_butterworth: bool = False,
        butterworth_cutoff: float = 8000.0
    ):
        """
        Inicializa o processador de áudio
        
        Args:
            sample_rate: Taxa de amostragem desejada (Hz)
            target_duration: Duração alvo em segundos
            normalize: Se deve normalizar o áudio
            reduce_noise: Se deve reduzir ruído
            use_butterworth: Se deve aplicar filtro Butterworth
            butterworth_cutoff: Frequência de corte do filtro Butterworth (Hz)
        """
        self.sample_rate = sample_rate
        self.target_duration = target_duration
        self.normalize = normalize
        self.reduce_noise = reduce_noise
        self.use_butterworth = use_butterworth
        self.butterworth_cutoff = butterworth_cutoff
    
    def load_audio(self, file_path: Union[str, Path]) -> Tuple[np.ndarray, int]:
        """
        Carrega arquivo de áudio
        
        Args:
            file_path: Caminho para o arquivo de áudio
            
        Returns:
            Tupla (audio_array, sample_rate)
        """
        audio, sr = librosa.load(file_path, sr=self.sample_rate, mono=True)
        return audio, sr
    
    def pad_or_truncate(self, audio: np.ndarray) -> np.ndarray:
        """
        Preenche ou trunca o áudio para duração alvo
        
        Args:
            audio: Array de áudio
            
        Returns:
            Áudio com duração padronizada
        """
        target_length = int(self.target_duration * self.sample_rate)
        
        if len(audio) > target_length:
            # Trunca o áudio
            audio = audio[:target_length]
        elif len(audio) < target_length:
            # Preenche com zeros
            padding = target_length - len(audio)
            audio = np.pad(audio, (0, padding), mode='constant')
        
        return audio
    
    def normalize_audio(self, audio: np.ndarray) -> np.ndarray:
        """
        Normaliza o áudio para amplitude [-1, 1]
        
        Args:
            audio: Array de áudio
            
        Returns:
            Áudio normalizado
        """
        max_val = np.max(np.abs(audio))
        if max_val > 0:
            audio = audio / max_val
        return audio
    
    def reduce_noise_audio(self, audio: np.ndarray) -> np.ndarray:
        """
        Reduz ruído do áudio usando noisereduce
        
        Args:
            audio: Array de áudio
            
        Returns:
            Áudio com ruído reduzido
        """
        try:
            audio_clean = nr.reduce_noise(y=audio, sr=self.sample_rate)
            return audio_clean
        except Exception as e:
            print(f"Erro ao reduzir ruído: {e}. Retornando áudio original.")
            return audio
    
    def apply_butterworth_filter(self, audio: np.ndarray) -> np.ndarray:
        """
        Aplica filtro Butterworth passa-baixa para remoção de ruído de alta frequência
        
        Args:
            audio: Array de áudio
            
        Returns:
            Áudio filtrado
        """
        # Normaliza frequência de corte pela frequência de Nyquist
        nyquist = self.sample_rate / 2.0
        normal_cutoff = self.butterworth_cutoff / nyquist
        
        # Cria filtro Butterworth passa-baixa de ordem 4
        b, a = signal.butter(4, normal_cutoff, btype='low', analog=False)
        
        # Aplica filtro bidirecional (filtfilt) para evitar deslocamento de fase
        filtered_audio = signal.filtfilt(b, a, audio)
        
        return filtered_audio
    
    def process(self, file_path: Union[str, Path]) -> np.ndarray:
        """
        Processa arquivo de áudio completo
        
        Args:
            file_path: Caminho para o arquivo de áudio
            
        Returns:
            Áudio processado como array numpy
        """
        # Carrega áudio
        audio, _ = self.load_audio(file_path)
        
        # Reduz ruído (se habilitado)
        if self.reduce_noise:
            audio = self.reduce_noise_audio(audio)
        
        # Aplica filtro Butterworth (se habilitado)
        if self.use_butterworth:
            audio = self.apply_butterworth_filter(audio)
        
        # Padroniza duração
        audio = self.pad_or_truncate(audio)
        
        # Normaliza (se habilitado)
        if self.normalize:
            audio = self.normalize_audio(audio)
        
        return audio
    
    def save_processed(self, audio: np.ndarray, output_path: Union[str, Path]):
        """
        Salva áudio processado
        
        Args:
            audio: Array de áudio processado
            output_path: Caminho para salvar
        """
        output_path = Path(output_path)
        output_path.parent.mkdir(parents=True, exist_ok=True)
        sf.write(output_path, audio, self.sample_rate)

