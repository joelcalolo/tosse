"""
Módulo para configuração da API Kaggle e download de datasets
"""
import os
import json
import zipfile
import tarfile
from pathlib import Path
from typing import Optional


def setup_kaggle_credentials(
    username: Optional[str] = None,
    key: Optional[str] = None,
    kaggle_json_path: Optional[str] = None
) -> bool:
    """
    Configura credenciais Kaggle no ambiente Colab
    
    Args:
        username: Nome de usuário Kaggle (opcional se usar kaggle_json_path)
        key: Chave API Kaggle (opcional se usar kaggle_json_path)
        kaggle_json_path: Caminho para arquivo kaggle.json (opcional)
        
    Returns:
        True se configuração foi bem-sucedida
    """
    kaggle_dir = Path.home() / ".kaggle"
    kaggle_dir.mkdir(exist_ok=True)
    
    kaggle_json = kaggle_dir / "kaggle.json"
    
    # Se arquivo já existe, não sobrescreve
    if kaggle_json.exists():
        print(f"Credenciais Kaggle já configuradas em {kaggle_json}")
        return True
    
    # Tenta usar arquivo fornecido
    if kaggle_json_path:
        source_path = Path(kaggle_json_path)
        if source_path.exists():
            import shutil
            shutil.copy(source_path, kaggle_json)
            print(f"Credenciais copiadas de {source_path} para {kaggle_json}")
        else:
            raise FileNotFoundError(f"Arquivo não encontrado: {kaggle_json_path}")
    
    # Ou usa username e key fornecidos
    elif username and key:
        credentials = {
            "username": username,
            "key": key
        }
        with open(kaggle_json, 'w') as f:
            json.dump(credentials, f)
        print(f"Credenciais Kaggle configuradas em {kaggle_json}")
    
    # Ou tenta usar variáveis de ambiente
    elif os.getenv('KAGGLE_USERNAME') and os.getenv('KAGGLE_KEY'):
        credentials = {
            "username": os.getenv('KAGGLE_USERNAME'),
            "key": os.getenv('KAGGLE_KEY')
        }
        with open(kaggle_json, 'w') as f:
            json.dump(credentials, f)
        print(f"Credenciais Kaggle configuradas a partir de variáveis de ambiente")
    
    else:
        raise ValueError(
            "Forneça username/key, kaggle_json_path, ou configure variáveis de ambiente "
            "KAGGLE_USERNAME e KAGGLE_KEY"
        )
    
    # Configura permissões (importante no Linux/Colab)
    os.chmod(kaggle_json, 0o600)
    
    return True


def download_icbhi_dataset(
    dataset_name: str = "vbookshelf/icbhi-2017-respiratory-sound-database",
    output_dir: str = "/content/tmp/icbhi",
    unzip: bool = True
) -> Path:
    """
    Baixa dataset ICBHI do Kaggle usando API
    
    Args:
        dataset_name: Nome do dataset no formato 'usuario/dataset'
        output_dir: Diretório para salvar dados baixados
        unzip: Se deve extrair arquivos automaticamente
        
    Returns:
        Caminho para diretório com dados extraídos
    """
    try:
        from kaggle.api.kaggle_api_extended import KaggleApi
    except ImportError:
        raise ImportError(
            "Biblioteca kaggle não instalada. Execute: pip install kaggle"
        )
    
    output_path = Path(output_dir)
    output_path.mkdir(parents=True, exist_ok=True)
    
    print(f"Baixando dataset {dataset_name} do Kaggle...")
    print(f"Diretório de destino: {output_path}")
    
    # Inicializa API Kaggle
    api = KaggleApi()
    api.authenticate()
    
    # Baixa dataset
    api.dataset_download_files(
        dataset=dataset_name,
        path=str(output_path),
        unzip=unzip
    )
    
    # Se não extraiu automaticamente, tenta extrair manualmente
    if not unzip:
        zip_files = list(output_path.glob("*.zip"))
        for zip_file in zip_files:
            print(f"Extraindo {zip_file.name}...")
            with zipfile.ZipFile(zip_file, 'r') as zip_ref:
                zip_ref.extractall(output_path)
            zip_file.unlink()  # Remove arquivo zip após extrair
        
        tar_files = list(output_path.glob("*.tar*"))
        for tar_file in tar_files:
            print(f"Extraindo {tar_file.name}...")
            with tarfile.open(tar_file, 'r:*') as tar_ref:
                tar_ref.extractall(output_path)
            tar_file.unlink()
    
    print(f"\nDataset baixado e extraído com sucesso!")
    print(f"Localização: {output_path.absolute()}")
    
    # Lista estrutura de diretórios
    print("\nEstrutura de diretórios:")
    for item in sorted(output_path.iterdir())[:10]:  # Mostra primeiros 10 itens
        if item.is_dir():
            print(f"  📁 {item.name}/")
        else:
            print(f"  📄 {item.name}")
    if len(list(output_path.iterdir())) > 10:
        print(f"  ... e mais {len(list(output_path.iterdir())) - 10} itens")
    
    return output_path


def find_diagnosis_file(data_dir: Path) -> Optional[Path]:
    """
    Encontra arquivo de diagnósticos no diretório do dataset
    
    Args:
        data_dir: Diretório raiz do dataset
        
    Returns:
        Caminho para arquivo de diagnósticos ou None
    """
    possible_names = [
        "patient_diagnosis.txt",
        "patient_diagnosis.csv",
        "Patient_Diagnosis.txt",
        "Patient_Diagnosis.csv",
        "diagnosis.txt",
        "diagnosis.csv"
    ]
    
    # Procura no diretório raiz
    for name in possible_names:
        file_path = data_dir / name
        if file_path.exists():
            return file_path
    
    # Procura recursivamente
    for name in possible_names:
        matches = list(data_dir.rglob(name))
        if matches:
            return matches[0]
    
    return None

