echo "updating mbSPLS website (jupyter book and github pages)"

# from mbSPLS directory

# remove current _build folder
jupyter-book clean ./docs/ --all

# save changes to markdown files to github (as backup)  
#git add .
#git commit -m 'save manual text changes'
#git push 

# build new html files (_build folder)
rm -rf .docs/_sources
jupyter-book build ./docs 

# add changes to mbSPLS website (hosted from gh-pages branch)
cp -R ./docs/_build/html/. ./docs/
git add . 
git commit -m 'updating manual website'
git push

echo "Done, changes to website should be visible in about 2min"
