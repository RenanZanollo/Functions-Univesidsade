create table universidade;

use universidade;

CREATE DATABASE Universidade;
USE Universidade;

CREATE TABLE Area (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL
);

CREATE TABLE Curso (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    id_area INT,
    FOREIGN KEY (id_area) REFERENCES Area(id)
);

CREATE TABLE Aluno (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    sobrenome VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE Matricula (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_aluno INT,
    id_curso INT,
    FOREIGN KEY (id_aluno) REFERENCES Aluno(id),
    FOREIGN KEY (id_curso) REFERENCES Curso(id),
    UNIQUE (id_aluno, id_curso)
);

DELIMITER //

CREATE PROCEDURE InserirCurso(IN nomeCurso VARCHAR(100), IN nomeArea VARCHAR(100))
BEGIN
    DECLARE areaID INT;

    SET areaID = (SELECT id FROM Area WHERE nome = nomeArea);
    IF areaID IS NULL THEN
        INSERT INTO Area (nome) VALUES (nomeArea);
        SET areaID = LAST_INSERT_ID();
    END IF;

    INSERT INTO Curso (nome, id_area) VALUES (nomeCurso, areaID);
END //

DELIMITER ;

DELIMITER //

CREATE FUNCTION GetCursoId(nomeCurso VARCHAR(100), nomeArea VARCHAR(100)) RETURNS INT
READS SQL DATA
BEGIN
    DECLARE cursoID INT;
    SELECT c.id INTO cursoID
    FROM Curso c
    JOIN Area a ON c.id_area = a.id
    WHERE c.nome = nomeCurso AND a.nome = nomeArea;
    RETURN cursoID;
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE MatricularAluno(IN nomeAluno VARCHAR(50), IN sobrenomeAluno VARCHAR(50), IN nomeCurso VARCHAR(100), IN nomeArea VARCHAR(100))
BEGIN
    DECLARE alunoID INT;
    DECLARE cursoID INT;
    DECLARE alunoEmail VARCHAR(100);

    SET alunoEmail = CONCAT(LOWER(nomeAluno), '.', LOWER(sobrenomeAluno), '@dominio.com');

    SET alunoID = (SELECT id FROM Aluno WHERE email = alunoEmail);
    IF alunoID IS NULL THEN
        INSERT INTO Aluno (nome, sobrenome, email) VALUES (nomeAluno, sobrenomeAluno, alunoEmail);
        SET alunoID = LAST_INSERT_ID();
    END IF;

    SET cursoID = GetCursoId(nomeCurso, nomeArea);

    IF NOT EXISTS (SELECT 1 FROM Matricula WHERE id_aluno = alunoID AND id_curso = cursoID) THEN
        INSERT INTO Matricula (id_aluno, id_curso) VALUES (alunoID, cursoID);
    END IF;
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE PopulaCursos()
BEGIN
    DECLARE i INT DEFAULT 1;
    WHILE i <= 25 DO
        CALL InserirCurso(CONCAT('Curso', i), CONCAT('Area', i));
        SET i = i + 1;
    END WHILE;
END //

DELIMITER ;

CALL PopulaCursos();

DELIMITER //

CREATE PROCEDURE PopulaAlunos()
BEGIN
    DECLARE i INT DEFAULT 1;
    WHILE i <= 200 DO
        CALL MatricularAluno(
            CONCAT('Nome', i), 
            CONCAT('Sobrenome', i), 
            CONCAT('Curso', FLOOR(1 + (RAND() * 25))), 
            CONCAT('Area', FLOOR(1 + (RAND() * 25)))
        );
        SET i = i + 1;
    END WHILE;
END //

DELIMITER ;

CALL PopulaAlunos();

CALL InserirCurso('ADS', 'Tecnologia');

CALL MatricularAluno('Renan', 'Zanollo', 'ADS', 'Tecnologia');
CALL MatricularAluno('Isabela', 'Queiroz', 'ADS', 'Tecnologia');

SELECT GetCursoId('ADS', 'Tecnologia') AS cursoID;



