# Assignment 2
## CS1217 Operating Systems (Spring 2023)
---

### Setting up Git on your Virtual Machines

You will need a Unix environment for this (MacOS, or Linux). 

Follow the sections **Generating a new SSH key** and **Adding your SSH key to the ssh-agent** from [this link](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent), and then follow the section **Adding a new SSH key to your account** from [this link](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account).

Make sure that you do this with the same GitHub Account that you're using to access the assignment. 

Finally, you will have to take one last step. Execute the following command on your Terminal (copy-paste this, because the placements of the apostrophes are important):

```
echo "Host github.com
  Hostname ssh.github.com
  Port 443" >> ~/.ssh/config
```

### Cloning this Repository

1. There will be a big green button saying *Code* at the top of the page. Click that, click on *Local* and then click on *SSH*. Copy the link that is shown there (it should start with something like ```git@github.com:...```). 
2. Open a Terminal on your VM, and run the command ```git clone [SSH URL]``` where ```[SSH URL]``` is what you copied in Step 1. 
3. Run ```ls```, and you will be able to see the name of the directory that the repository got cloned to.
4. Run ```cd [DIRECTORY NAME]``` where ```[DIRECTORY NAME]``` is the name of the repository directory that you saw in Step 3.

Those are all the cloned files. If you're using a Desktop Version of Ubuntu, you will be able to find this cloned folder in your Home directory. Use these files during the assignment. 
