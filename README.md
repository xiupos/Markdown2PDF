# md2pdf

1. `main.md`を編集して
2. `references.bib`を編集して
3. 使用画像を`./src/img`に入れて
4. `make`を実行すると
5. PDFが出来ます

詳しくは [Wiki](https://github.com/xiupos/md2pdf/wiki) を参照.

## テンプレートリポジトリの実装更新を取り入れる

```
git remote add template https://github.com/xiupos/md2pdf.git
git fetch template
git merge template/master --allow-unrelated-histories
```
