# Psets for Econ-244

## Installation

If you are reading this, then you have a Github account. However, to work on your computer and interact with the repository, you'll need git on your own computer. You can download git at [this link](https://git-scm.com/downloads).

Once you have installed git, you can access git via the **command line**. Christina, for mac, you will access this through the **terminal**. Sam, for Windows, you will access this via the git command line. There are GUI options, but I find them quite complicated. For the rest of this guide, when I mention **command line** I will mean the terminal for Christina and the git command line tool for Sam. 

To check that you have git correctly installed, open the command line and type

```
git --version
```

You will need to configure your git with some identifying information so that when you make changes to a repo, the changes are attributed to you. To do this, type

```
git config --global user.name "Preston Mui"
git config --global user.email "mui@berkeley.edu"
```

Where you replace my name and email with yours. I think you are supposed to use the same email that you used for Github.

(Oh! and you'll need a GitHub account, too).

## Cloning the repository

The git model is to have a central **repository** stored on github. Each of us will have our own **local** copies of the repository. To get hooked up with the central repository, you will need to **clone** it. Open the command line and navigate to your folder and type

```
git clone https://github.com/PrestonMui/244-psets
```

You should be prompted to 
this will create a folder called ```244-psets``` in the working directory, with the contents of the git repo. You can change the name of this folder however you please. So, for example, I have a folder on my computer at ```Dropbox/berkeley/244```. I navigated to that folder and cloned the repo there, creating ```Dropbox/berkeley/244/244-psets```.

Git will automatically know that you are tracking this repo. When you track a foreign repository, this is called a **remote**. Each remote has a different name; since you cloned the github repo, the remote is known as **origin**. In theory you can track many different repos, but since we only have one upstream remote we need only deal with origin.

## Updating your local files

Say you clone the repository, and go to sleep. Overnight, Peter has done some work. Maybe he's added a file, or fixed an error in some .tex file. He's pushed (to be covered later) the changes to the github repository. Then, you wake up and decide to work on the problem set. Before you start work, you decide to make sure your local files are up-to-date with the central repo.

If you type

```
git status
```

You should receive a message that says you are "up-to-date" with the origin. But, Peter made changes! Git doesn't yet know that there were changes at the master branch. To ask git to **fetch** those changes, type

```
git fetch
```

Git will go to github and find out what changes were made to **origin**. Type ```git status``` once more to see if there are any new updates. If there are, you can type

```
git pull
```

This "plays" the new changes on top of your files. It basically does whatever changes happened on remote on your local files. One useful thing to note is that this is done line-by-line. So, say Peter and I are working at the same time, and he edits line 50 of a file and I edit line 100. We've both made changes on our local machines, but he's pushed them to Github already. I can pull his changes from Github and apply his change to my file (so that I have both his edits and my edits). I can then also push my changes, and he can pull them. The cool thing about this is that we can work on different parts of the file at the same time, and git is smart enough to know how to merge those changes.

## Make changes and pushing them to the local repository

Say you want to add or modify a file. You simply make the changes on your computer, record the commits, and send the commits to Github. So, say you get started on the first problem set: You create the file ```pset1.tex``` and save it on your computer. If you go to the command line and type ```git status``` you should receive something like the following

```
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

	new file:   pset1.tex
```

So git seems to know that you've changed something. To **commit** your changes, you need to select what files you want to change. So, type

```
git add pset1.tex
git status
Changes to be committed:
  (use "git reset HEAD <file>..." to unstage)

	new file:   pset1.tex

```

Once you are satisfied, you can finalize the commit:

```
git commit -m "Added pset1.tex"
```

The ```-m``` means "message." Every commit must have a message associated with it. The message should be short but descriptive. Finally, you can push your changes to the repository:

```
git push origin master
```

which will prompt you for your github login. You're done! To reiterate, the process was:

1. Make changes in your local repository
2. Decide what files you want to commit with ```git add```
3. Record the commit with a message using ```git commit```
4. Push the changes to the repository using ```git push```

Some things to note are
- If you do not add a file, it does not get committed. If it's not committed, it doesn't get pushed.
- Commits should be small, if possible. So, do not add all of question one and make some changes in question two as well. The reason is that git records changes line by line, and git cannot split up commits. So, if I want to apply your commit to my files, I apply all of the commit or none of it. So, if the commits are small this minimizes chances of accidental overlaps.
- You don't have to track every file. In fact, it makes sense for the only files we track to be .tex files and .do files (for obvious reasons) and .pdf files (so we can view them on github). Other files such as .latexmk or .aux files are unnecessary -- as long as we have the .tex file we can run the .tex file.
