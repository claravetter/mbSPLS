echo "updating mbSPLS website (jupyter book and github pages)"

# from mbSPLS directory

# remove current _build folder
#jupyter-book clean ./docs/ --all

# save changes to markdown files to github (as backup)  
#git add .
#git commit -m 'save manual text changes'
#git push 

# build new html files (_build folder)
jupyter-book build ./docs 

# add changes to mbSPLS website (hosted from gh-pages branch)
git checkout gh-pages
cp -R docs/_build/html/. .
#cp -R docs/Downloads .
git add . 
git commit -m 'updating manual website'
git push -u origin gh-pages     
git checkout main 

echo "Done, changes to website should be visible in about 2min"