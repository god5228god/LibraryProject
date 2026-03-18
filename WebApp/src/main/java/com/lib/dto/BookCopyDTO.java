package com.lib.dto;

public class BookCopyDTO {
    private String bookId;
    private String isbn;
    private String bookStatusId;

    public String getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(String createdAt) {
        this.createdAt = createdAt;
    }

    public String getBookStatusId() {
        return bookStatusId;
    }

    public void setBookStatusId(String bookStatusId) {
        this.bookStatusId = bookStatusId;
    }

    public String getIsbn() {
        return isbn;
    }

    public void setIsbn(String isbn) {
        this.isbn = isbn;
    }

    public String getBookId() {
        return bookId;
    }

    public void setBookId(String bookId) {
        this.bookId = bookId;
    }

    private String createdAt;
}
