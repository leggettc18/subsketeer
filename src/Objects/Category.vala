/*
 * SPDX-License-Identifier: MIT
 * SPDX-FileCopyrightText: 2021 Christopher Leggett <chris@leggett.dev>
 */

public class Category {
    public int id;
    public string name;
    public CategoryColor color;
    public DateTime date_created;
    public DateTime date_modified;

    public Category () {}
}

public enum CategoryColor {
    STRAWBERRY, ORANGE, BANANA, LIME, MINT, BLUEBERRY,
    GRAPE, BUBBLEGUM, COCOA, SILVER, SLATE, BLACK;
}
