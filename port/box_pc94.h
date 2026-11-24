/* SPDX-License-Identifier: MIT
 * Copyright (c) 2026 abdulahmad and contributors
 *
 * The box for NHL 94 PC (overbar/box.h): the 3D scene (box_pc94.c) and the 2D install on a 486 (box_install.c).
 */
#ifndef BOX_PC94_H
#define BOX_PC94_H
#include <overbar/box.h>

extern const bx_scene BOX_PC94;
void box_pc94_arranged(void);                             /* back from the install: the box laid out */
void box_install_start(void);
int box_install_up(void);
void box_install_draw(void);
void box_install_back(void);
void box_install_skip(int);
#endif
