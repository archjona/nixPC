#!/usr/bin/env bash
set -euo pipefail
NAME="${1:?Usage: qt-new <ProjectName>}"

mkdir -p "$NAME"/{src,include,resources,ui}
cd "$NAME"

cat > CMakeLists.txt <<EOF
cmake_minimum_required(VERSION 3.21)
project($NAME VERSION 0.1 LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOUIC_SEARCH_PATHS "\${CMAKE_SOURCE_DIR}/ui")
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

find_package(Qt6 REQUIRED COMPONENTS Core Widgets)
qt_standard_project_setup()

qt_add_executable(\${PROJECT_NAME}
    src/main.cpp
    src/mainwindow.cpp
    include/mainwindow.h
    ui/mainwindow.ui
)

target_include_directories(\${PROJECT_NAME} PRIVATE include)
target_link_libraries(\${PROJECT_NAME} PRIVATE Qt6::Core Qt6::Widgets)
EOF

cat > include/mainwindow.h <<'EOF'
#pragma once
#include <QMainWindow>

QT_BEGIN_NAMESPACE
namespace Ui { class MainWindow; }
QT_END_NAMESPACE

class MainWindow : public QMainWindow {
    Q_OBJECT
public:
    explicit MainWindow(QWidget *parent = nullptr);
    ~MainWindow() override;
private:
    Ui::MainWindow *ui;
};
EOF

cat > src/mainwindow.cpp <<'EOF'
#include "mainwindow.h"
#include "ui_mainwindow.h"

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent), ui(new Ui::MainWindow) {
    ui->setupUi(this);
}

MainWindow::~MainWindow() { delete ui; }
EOF

cat > src/main.cpp <<'EOF'
#include <QApplication>
#include "mainwindow.h"

int main(int argc, char *argv[]) {
    QApplication app(argc, argv);
    MainWindow w;
    w.show();
    return app.exec();
}
EOF

cat > ui/mainwindow.ui <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<ui version="4.0">
 <class>MainWindow</class>
 <widget class="QMainWindow" name="MainWindow">
  <property name="windowTitle"><string>MainWindow</string></property>
  <widget class="QWidget" name="centralwidget"/>
 </widget>
 <resources/>
 <connections/>
</ui>
EOF

cat > .gitignore <<'EOF'
build/
.cache/
compile_commands.json
result
EOF

echo "✓ Qt-Projekt '$NAME' erstellt"
echo ""
echo "  cd $NAME"
echo "  qt-dev               # in Qt-Shell wechseln"
echo "  nvim ."
echo "  → <leader>cv (Debug) → <leader>cg → <leader>cb → <leader>cr"
