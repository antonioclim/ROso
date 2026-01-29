"""
Teste pentru Quiz Formativ - Seminar 01
Sisteme de Operare | ASE București - CSIE
"""

import json
from pathlib import Path

import pytest
import yaml


# ═══════════════════════════════════════════════════════════════════
# Fixtures
# ═══════════════════════════════════════════════════════════════════

@pytest.fixture
def quiz_path():
    """Returnează calea către quiz.yaml."""
    return Path(__file__).parent.parent / "formative" / "quiz.yaml"


@pytest.fixture
def quiz_data(quiz_path):
    """Încarcă datele din quiz.yaml."""
    with open(quiz_path, encoding='utf-8') as f:
        return yaml.safe_load(f)


# ═══════════════════════════════════════════════════════════════════
# Teste pentru quiz.yaml
# ═══════════════════════════════════════════════════════════════════

class TestQuizYaml:
    """Teste pentru structura quiz.yaml."""
    
    def test_quiz_file_exists(self, quiz_path):
        """Verifică existența fișierului quiz.yaml."""
        assert quiz_path.exists(), f"Fișierul {quiz_path} nu există"
    
    def test_quiz_has_metadata(self, quiz_data):
        """Verifică prezența metadatelor."""
        assert 'metadata' in quiz_data
        meta = quiz_data['metadata']
        assert 'titlu' in meta
        assert 'seminar' in meta
        assert 'timp_estimat' in meta
    
    def test_quiz_has_questions(self, quiz_data):
        """Verifică prezența întrebărilor."""
        assert 'intrebari' in quiz_data
        assert len(quiz_data['intrebari']) >= 5
    
    def test_question_structure(self, quiz_data):
        """Verifică structura fiecărei întrebări."""
        required_fields = ['id', 'tip', 'bloom', 'text', 'optiuni', 'corect', 'explicatie']
        for q in quiz_data['intrebari']:
            for field in required_fields:
                assert field in q, f"Întrebarea {q.get('id', 'N/A')} nu are câmpul {field}"
    
    def test_correct_answer_valid(self, quiz_data):
        """Verifică că răspunsul corect e valid."""
        for q in quiz_data['intrebari']:
            valid_answers = [chr(ord('A') + i) for i in range(len(q['optiuni']))]
            assert q['corect'] in valid_answers, \
                f"Întrebarea {q['id']}: răspuns corect invalid {q['corect']}"
    
    def test_bloom_levels_valid(self, quiz_data):
        """Verifică nivelurile Bloom."""
        valid_blooms = ['remember', 'understand', 'apply', 'analyse', 'evaluate', 'create']
        for q in quiz_data['intrebari']:
            assert q['bloom'] in valid_blooms, \
                f"Întrebarea {q['id']}: nivel Bloom invalid {q['bloom']}"
    
    def test_bloom_distribution(self, quiz_data):
        """Verifică distribuția nivelurilor Bloom."""
        blooms = [q['bloom'] for q in quiz_data['intrebari']]
        bloom_counts = {b: blooms.count(b) for b in set(blooms)}
        # Verifică că avem cel puțin 2 niveluri diferite
        assert len(bloom_counts) >= 2, "Quiz-ul trebuie să acopere cel puțin 2 niveluri Bloom"


# ═══════════════════════════════════════════════════════════════════
# Teste pentru quiz_lms.json
# ═══════════════════════════════════════════════════════════════════

@pytest.fixture
def lms_path():
    """Returnează calea către quiz_lms.json."""
    return Path(__file__).parent.parent / "formative" / "quiz_lms.json"


@pytest.fixture
def lms_data(lms_path):
    """Încarcă datele din quiz_lms.json."""
    with open(lms_path, encoding='utf-8') as f:
        return json.load(f)


class TestQuizLmsJson:
    """Teste pentru structura quiz_lms.json."""
    
    def test_lms_file_exists(self, lms_path):
        """Verifică existența fișierului quiz_lms.json."""
        assert lms_path.exists()
    
    def test_lms_valid_json(self, lms_path):
        """Verifică că JSON-ul este valid."""
        with open(lms_path, encoding='utf-8') as f:
            data = json.load(f)
        assert data is not None
    
    def test_lms_has_quiz_settings(self, lms_data):
        """Verifică setările quiz-ului."""
        assert 'quiz' in lms_data
        assert 'title' in lms_data['quiz']
        assert 'time_limit_minutes' in lms_data['quiz']
    
    def test_lms_has_questions(self, lms_data):
        """Verifică prezența întrebărilor."""
        assert 'questions' in lms_data
        assert len(lms_data['questions']) >= 5
    
    def test_lms_question_has_correct_answer(self, lms_data):
        """Verifică că fiecare întrebare are un răspuns corect."""
        for q in lms_data['questions']:
            correct_answers = [a for a in q['answers'] if a.get('correct', False)]
            assert len(correct_answers) == 1, \
                f"Întrebarea {q['id']} trebuie să aibă exact 1 răspuns corect"


# ═══════════════════════════════════════════════════════════════════
# Teste de consistență
# ═══════════════════════════════════════════════════════════════════

class TestQuizConsistency:
    """Verifică consistența între quiz.yaml și quiz_lms.json."""
    
    @pytest.fixture
    def yaml_path(self):
        return Path(__file__).parent.parent / "formative" / "quiz.yaml"
    
    @pytest.fixture
    def json_path(self):
        return Path(__file__).parent.parent / "formative" / "quiz_lms.json"
    
    def test_same_number_of_questions(self, yaml_path, json_path):
        """Verifică că ambele fișiere au același număr de întrebări."""
        with open(yaml_path, encoding='utf-8') as f:
            yaml_data = yaml.safe_load(f)
        with open(json_path, encoding='utf-8') as f:
            json_data = json.load(f)
        
        yaml_count = len(yaml_data.get('intrebari', []))
        json_count = len(json_data.get('questions', []))
        
        assert yaml_count == json_count, \
            f"Număr diferit de întrebări: YAML={yaml_count}, JSON={json_count}"
