<?php

function uploadFileTo(string $uploadDir, string $fieldName = 'uploadfile', ?string &$storedFileName = null): bool
{
    if (empty($_FILES[$fieldName]['tmp_name']) || !is_uploaded_file($_FILES[$fieldName]['tmp_name'])) {
        return false;
    }
    if (!is_dir($uploadDir)) {
        mkdir($uploadDir, 0777, true);
    }
  
    $originalName = basename($_FILES[$fieldName]['name']);
    $baseName = preg_replace('/[^A-Za-z0-9_-]/', '_', pathinfo($originalName, PATHINFO_FILENAME));
    $extension = strtolower(pathinfo($originalName, PATHINFO_EXTENSION));
    $storedFileName = time() . '_' . $baseName;

    if ($extension !== '') {
        $storedFileName .= '.' . $extension;
    }

    return move_uploaded_file(
        $_FILES[$fieldName]['tmp_name'],
        rtrim($uploadDir, '/\\') . DIRECTORY_SEPARATOR . $storedFileName
    );
}

function uploadAndRenameFile(string $uploadDir, string $newFileName, string $fieldName = 'uploadfile'): bool
{
    if (empty($_FILES[$fieldName]['tmp_name']) || !is_uploaded_file($_FILES[$fieldName]['tmp_name'])) {
        return false;
    }

    if (!is_dir($uploadDir)) {
        mkdir($uploadDir, 0777, true);
    }

    $extension = strtolower(pathinfo($_FILES[$fieldName]['name'], PATHINFO_EXTENSION));
    $finalName = $newFileName;

    if ($extension !== '' && pathinfo($newFileName, PATHINFO_EXTENSION) === '') {
        $finalName .= '.' . $extension;
    }

    return move_uploaded_file(
        $_FILES[$fieldName]['tmp_name'],
        rtrim($uploadDir, '/\\') . DIRECTORY_SEPARATOR . $finalName
    );
}
