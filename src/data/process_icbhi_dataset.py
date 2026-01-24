"""
Script principal para processar dataset ICBHI completo
Realiza filtragem, padronização, limpeza, extração de características e organização
"""
import os
import sys
import pandas as pd
import numpy as np
from pathlib import Path
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder
import argparse
from tqdm import tqdm

# Adiciona o diretório raiz ao path
sys.path.append(str(Path(__file__).parent.parent.parent))

from src.preprocessing.audio_processor import AudioProcessor
from src.features.feature_extractor import FeatureExtractor


def find_audio_files(data_dir: Path, patient_id: str) -> list:
    """
    Encontra arquivos de áudio para um Patient_ID específico
    
    Args:
        data_dir: Diretório raiz dos dados ICBHI
        patient_id: ID do paciente
        
    Returns:
        Lista de caminhos para arquivos de áudio
    """
    audio_files = []
    
    # Procura em subdiretórios comuns do ICBHI
    search_paths = [
        data_dir / "audio_and_txt_files",
        data_dir / "audio_files",
        data_dir,
    ]
    
    # Também procura por padrões comuns de nomeação
    patterns = [
        f"*{patient_id}*.wav",
        f"{patient_id}_*.wav",
        f"*_{patient_id}.wav",
    ]
    
    for search_path in search_paths:
        if search_path.exists():
            for pattern in patterns:
                audio_files.extend(list(search_path.glob(pattern)))
    
    # Remove duplicatas
    return list(set(audio_files))


def load_and_filter_diagnosis(csv_path: Path) -> pd.DataFrame:
    """
    Carrega e filtra o arquivo de diagnósticos incluindo TODAS as classes relevantes
    Mapeia para 3 classes finais: Pneumonia, Bronchitis, Healthy
    
    Args:
        csv_path: Caminho para o arquivo CSV de diagnósticos
        
    Returns:
        DataFrame filtrado com Pneumonia, Bronchitis e Healthy (mapeados para 3 classes)
    """
    # Tenta diferentes separadores e nomes de coluna
    try:
        # Tenta CSV padrão
        df = pd.read_csv(csv_path, sep=',')
    except:
        try:
            # Tenta separador por tabulação
            df = pd.read_csv(csv_path, sep='\t')
        except:
            # Tenta sem header
            df = pd.read_csv(csv_path, sep=',', header=None)
            df.columns = ['Patient_ID', 'Disease']
    
    # Normaliza nomes de colunas
    df.columns = df.columns.str.strip()
    if 'Patient_ID' not in df.columns:
        df.columns = ['Patient_ID', 'Disease']
    
    # Incluir TODAS as doenças relevantes e mapear para 3 classes
    # Classe 0: Pneumonia
    pneumonia_diseases = ['Pneumonia', 'pneumonia', 'URTI', 'urti']
    # Classe 1: Bronchitis (Bronquite)
    bronchitis_diseases = ['Bronchitis', 'bronchitis', 'Bronchiolitis', 'bronchiolitis', 
                           'COPD', 'copd', 'Asthma', 'asthma']
    # Classe 2: Healthy (Normal)
    normal_diseases = ['Healthy', 'healthy', 'Normal', 'normal']
    
    # Todas as doenças que queremos processar
    target_diseases = pneumonia_diseases + bronchitis_diseases + normal_diseases
    
    # Filtrar apenas doenças relevantes
    filtered_df = df[df['Disease'].isin(target_diseases)].copy()
    
    # Mapear para classes finais
    def map_to_class(disease):
        disease_lower = str(disease).lower().strip()
        if disease_lower in ['pneumonia', 'urti']:
            return 'Pneumonia'
        elif disease_lower in ['bronchitis', 'bronchiolitis', 'copd', 'asthma']:
            return 'Bronchitis'
        elif disease_lower in ['healthy', 'normal']:
            return 'Healthy'
        else:
            return disease
    
    filtered_df['Disease'] = filtered_df['Disease'].apply(map_to_class)
    
    # Normaliza nomes das doenças
    filtered_df['Disease'] = filtered_df['Disease'].str.capitalize()
    
    print(f"Total de pacientes no CSV: {len(df)}")
    print(f"Pacientes filtrados (relevantes): {len(filtered_df)}")
    print(f"Distribuição por doença:\n{filtered_df['Disease'].value_counts()}")
    
    return filtered_df


def process_icbhi_dataset(
    data_dir: str,
    diagnosis_csv: str,
    output_dir: str = "processed_data",
    sample_rate: int = 16000,
    use_butterworth: bool = True,
    butterworth_cutoff: float = 8000.0,
    extract_mfcc: bool = True,
    extract_mel: bool = True,
    train_ratio: float = 0.7,
    val_ratio: float = 0.15,
    test_ratio: float = 0.15,
    random_state: int = 42
):
    """
    Processa dataset ICBHI completo conforme requisitos do projeto
    
    Args:
        data_dir: Diretório raiz do dataset ICBHI
        diagnosis_csv: Caminho para arquivo patient_diagnosis.csv
        output_dir: Diretório para salvar dados processados
        sample_rate: Taxa de amostragem desejada (Hz)
        use_butterworth: Se deve aplicar filtro Butterworth
        butterworth_cutoff: Frequência de corte do filtro (Hz)
        extract_mfcc: Se deve extrair características MFCC
        extract_mel: Se deve extrair espectrogramas Mel
        train_ratio: Proporção de dados de treino
        val_ratio: Proporção de dados de validação
        test_ratio: Proporção de dados de teste
        random_state: Seed para reprodutibilidade
    """
    data_dir = Path(data_dir)
    diagnosis_csv = Path(diagnosis_csv)
    output_dir = Path(output_dir)
    
    # Cria diretório de saída
    output_dir.mkdir(parents=True, exist_ok=True)
    
    print("="*60)
    print("PROCESSAMENTO DO DATASET ICBHI")
    print("="*60)
    
    # 1. FILTRAGEM: Carrega e filtra diagnósticos
    print("\n[1/5] Filtrando diagnósticos...")
    diagnosis_df = load_and_filter_diagnosis(diagnosis_csv)
    
    # 2. Inicializa processadores
    print("\n[2/5] Inicializando processadores...")
    processor = AudioProcessor(
        sample_rate=sample_rate,
        normalize=True,
        reduce_noise=False,  # Usaremos apenas Butterworth conforme requisito
        use_butterworth=use_butterworth,
        butterworth_cutoff=butterworth_cutoff
    )
    
    extractor = FeatureExtractor(sample_rate=sample_rate)
    
    # 3. Processa áudios e extrai características
    print("\n[3/5] Processando áudios e extraindo características...")
    
    mfcc_features = []
    mel_features = []
    labels = []
    patient_ids = []
    audio_paths = []
    
    processed_count = 0
    error_count = 0
    
    for idx, row in tqdm(diagnosis_df.iterrows(), total=len(diagnosis_df), desc="Processando"):
        patient_id = str(row['Patient_ID']).strip()
        disease = row['Disease']
        
        # Encontra arquivos de áudio para este paciente
        audio_files = find_audio_files(data_dir, patient_id)
        
        if not audio_files:
            # Se não encontrou, tenta procurar recursivamente
            audio_files = list(data_dir.rglob(f"*{patient_id}*.wav"))
        
        if not audio_files:
            print(f"\nAviso: Nenhum arquivo de áudio encontrado para paciente {patient_id}")
            error_count += 1
            continue
        
        # Processa cada arquivo de áudio encontrado
        for audio_file in audio_files:
            try:
                # PADRONIZAÇÃO: Carrega e padroniza áudio
                audio = processor.process(audio_file)
                
                # EXTRAÇÃO DE CARACTERÍSTICAS
                features_dict = {}
                
                if extract_mfcc:
                    # Extrai MFCC com deltas
                    mfcc = extractor.extract_mfcc(audio, delta=True, delta2=True)
                    features_dict['mfcc'] = mfcc
                
                if extract_mel:
                    # Extrai Espectrograma Log-Mel para CNN
                    mel_spec = extractor.extract_mel_spectrogram(audio)
                    features_dict['mel'] = mel_spec
                
                # Armazena características
                if extract_mfcc:
                    mfcc_features.append(features_dict.get('mfcc'))
                if extract_mel:
                    mel_features.append(features_dict.get('mel'))
                
                labels.append(disease)
                patient_ids.append(patient_id)
                audio_paths.append(str(audio_file))
                processed_count += 1
                
            except Exception as e:
                print(f"\nErro ao processar {audio_file}: {e}")
                error_count += 1
                continue
    
    print(f"\nProcessamento concluído:")
    print(f"  - Arquivos processados com sucesso: {processed_count}")
    print(f"  - Erros: {error_count}")
    
    if processed_count == 0:
        raise ValueError("Nenhum arquivo foi processado com sucesso!")
    
    # Converte para arrays numpy
    if extract_mfcc:
        mfcc_features = np.array(mfcc_features)
    if extract_mel:
        mel_features = np.array(mel_features)
    labels = np.array(labels)
    
    # 4. ORGANIZAÇÃO: Divide em conjuntos de treino, validação e teste
    print("\n[4/5] Dividindo dados em conjuntos de treino, validação e teste...")
    
    # Codifica labels
    label_encoder = LabelEncoder()
    labels_encoded = label_encoder.fit_transform(labels)
    
    # Divide dados
    # Primeiro separa treino do resto
    if extract_mel:
        X_temp, X_test, y_temp, y_test = train_test_split(
            mel_features, labels_encoded,
            test_size=test_ratio,
            random_state=random_state,
            stratify=labels_encoded
        )
        # Depois separa validação do treino
        val_size_adjusted = val_ratio / (train_ratio + val_ratio)
        X_train, X_val, y_train, y_val = train_test_split(
            X_temp, y_temp,
            test_size=val_size_adjusted,
            random_state=random_state,
            stratify=y_temp
        )
    else:
        # Se não usar mel, usa MFCC
        X_temp, X_test, y_temp, y_test = train_test_split(
            mfcc_features, labels_encoded,
            test_size=test_ratio,
            random_state=random_state,
            stratify=labels_encoded
        )
        val_size_adjusted = val_ratio / (train_ratio + val_ratio)
        X_train, X_val, y_train, y_val = train_test_split(
            X_temp, y_temp,
            test_size=val_size_adjusted,
            random_state=random_state,
            stratify=y_temp
        )
    
    print(f"\nDivisão dos dados:")
    print(f"  - Treino: {len(X_train)} amostras ({len(X_train)/processed_count*100:.1f}%)")
    print(f"  - Validação: {len(X_val)} amostras ({len(X_val)/processed_count*100:.1f}%)")
    print(f"  - Teste: {len(X_test)} amostras ({len(X_test)/processed_count*100:.1f}%)")
    
    # 5. SALVAMENTO: Salva características em arquivos .npy
    print("\n[5/5] Salvando características processadas...")
    
    # Salva características principais (Mel para CNN)
    if extract_mel:
        np.save(output_dir / "X_train_mel.npy", X_train)
        np.save(output_dir / "X_val_mel.npy", X_val)
        np.save(output_dir / "X_test_mel.npy", X_test)
        print(f"  - Espectrogramas Mel salvos em {output_dir}")
    
    # Salva MFCC se extraído
    if extract_mfcc:
        mfcc_train, mfcc_temp, mfcc_test = train_test_split(
            mfcc_features, labels_encoded,
            test_size=test_ratio,
            random_state=random_state,
            stratify=labels_encoded
        )
        mfcc_val_size = val_ratio / (train_ratio + val_ratio)
        mfcc_train_final, mfcc_val_final, _, _ = train_test_split(
            mfcc_train, mfcc_train,
            test_size=mfcc_val_size,
            random_state=random_state
        )
        
        np.save(output_dir / "X_train_mfcc.npy", mfcc_train_final)
        np.save(output_dir / "X_val_mfcc.npy", mfcc_val_final)
        np.save(output_dir / "X_test_mfcc.npy", mfcc_test)
        print(f"  - Características MFCC salvas em {output_dir}")
    
    # Salva labels
    np.save(output_dir / "y_train.npy", y_train)
    np.save(output_dir / "y_val.npy", y_val)
    np.save(output_dir / "y_test.npy", y_test)
    
    # Salva metadados
    metadata = {
        'label_encoder_classes': label_encoder.classes_.tolist(),
        'num_classes': len(label_encoder.classes_),
        'sample_rate': sample_rate,
        'processed_count': processed_count,
        'train_count': len(X_train),
        'val_count': len(X_val),
        'test_count': len(X_test),
        'feature_shapes': {}
    }
    
    if extract_mel:
        metadata['feature_shapes']['mel'] = {
            'train': X_train.shape,
            'val': X_val.shape,
            'test': X_test.shape
        }
    if extract_mfcc:
        metadata['feature_shapes']['mfcc'] = {
            'train': mfcc_train_final.shape if extract_mfcc else None,
            'val': mfcc_val_final.shape if extract_mfcc else None,
            'test': mfcc_test.shape if extract_mfcc else None
        }
    
    import json
    with open(output_dir / "metadata.json", 'w') as f:
        json.dump(metadata, f, indent=2)
    
    print(f"\n  - Labels e metadados salvos em {output_dir}")
    print(f"\n{'='*60}")
    print("PROCESSAMENTO CONCLUÍDO COM SUCESSO!")
    print(f"{'='*60}")
    print(f"\nDados processados salvos em: {output_dir.absolute()}")
    print(f"\nArquivos gerados:")
    if extract_mel:
        print(f"  - X_train_mel.npy, X_val_mel.npy, X_test_mel.npy")
    if extract_mfcc:
        print(f"  - X_train_mfcc.npy, X_val_mfcc.npy, X_test_mfcc.npy")
    print(f"  - y_train.npy, y_val.npy, y_test.npy")
    print(f"  - metadata.json")
    
    return output_dir


def main():
    parser = argparse.ArgumentParser(
        description='Processa dataset ICBHI completo conforme requisitos do projeto'
    )
    parser.add_argument('--data_dir', type=str, required=True,
                       help='Diretório raiz do dataset ICBHI')
    parser.add_argument('--diagnosis_csv', type=str, required=True,
                       help='Caminho para arquivo patient_diagnosis.csv')
    parser.add_argument('--output_dir', type=str, default='processed_data',
                       help='Diretório para salvar dados processados')
    parser.add_argument('--sample_rate', type=int, default=16000,
                       help='Taxa de amostragem (Hz)')
    parser.add_argument('--use_butterworth', action='store_true',
                       help='Aplicar filtro Butterworth')
    parser.add_argument('--butterworth_cutoff', type=float, default=8000.0,
                       help='Frequência de corte do filtro Butterworth (Hz)')
    parser.add_argument('--extract_mfcc', action='store_true',
                       help='Extrair características MFCC')
    parser.add_argument('--extract_mel', action='store_true', default=True,
                       help='Extrair espectrogramas Mel (padrão: True)')
    parser.add_argument('--train_ratio', type=float, default=0.7,
                       help='Proporção de dados de treino')
    parser.add_argument('--val_ratio', type=float, default=0.15,
                       help='Proporção de dados de validação')
    parser.add_argument('--test_ratio', type=float, default=0.15,
                       help='Proporção de dados de teste')
    
    args = parser.parse_args()
    
    process_icbhi_dataset(
        data_dir=args.data_dir,
        diagnosis_csv=args.diagnosis_csv,
        output_dir=args.output_dir,
        sample_rate=args.sample_rate,
        use_butterworth=args.use_butterworth,
        butterworth_cutoff=args.butterworth_cutoff,
        extract_mfcc=args.extract_mfcc,
        extract_mel=args.extract_mel,
        train_ratio=args.train_ratio,
        val_ratio=args.val_ratio,
        test_ratio=args.test_ratio
    )


if __name__ == '__main__':
    main()

