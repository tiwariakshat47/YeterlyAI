#import  needed libraries and check the used gpu
import torch
from torch import nn,optim
from torchvision import transforms, models ,datasets
import math
from tqdm import tqdm
from colorama import Fore,Style
import sys

#print used Device
print(f"Device used: {torch.cuda.get_device_name(0)}")

#transforms
train_path='asl_alphabet_train'
valid_path='asl_alphabet_valid'

train_transforms = transforms.Compose([transforms.Resize((224,224)),
                                       transforms.RandomRotation(30),
                                       transforms.RandomHorizontalFlip(p=0.3),
                                       transforms.ToTensor(),
                                       transforms.Normalize([0.485, 0.456, 0.406],
                                                            [0.229, 0.224, 0.225])])

test_transforms = transforms.Compose([transforms.Resize((224,224)),
                                      transforms.ToTensor(),
                                      transforms.Normalize([0.485, 0.456, 0.406],
                                                            [0.229, 0.224, 0.225])])

#load data to loaders
train_data = datasets.ImageFolder(train_path, transform=train_transforms)
test_data = datasets.ImageFolder(valid_path, transform=test_transforms)

trainloader = torch.utils.data.DataLoader(train_data, batch_size=512, shuffle=True)
testloader = torch.utils.data.DataLoader(test_data, batch_size=512)

model = models.mobilenet_v2(weights=models.MobileNet_V2_Weights.DEFAULT)

for param in model.parameters():
    param.requires_grad = False

#define new classifier and append it to network but remember to have a 29-neuron output layer for our two classes.
model.classifier= nn.Sequential(nn.Dropout(p=0.6, inplace=False),
                                nn.Linear(in_features=1280, out_features=29, bias=True),
                                nn.LogSoftmax(dim=1))

#unlock last three blocks before the classifier(last layer).
for p in model.features[-3:].parameters():
    p.requires_grad = True  
    
#choose your loss function
criterion = nn.NLLLoss()

optimizer = optim.Adam([{'params':model.features[-1].parameters()},
                        {'params':model.features[-2].parameters()},
                        {'params':model.features[-3].parameters()},
                        {'params':model.classifier.parameters()}], lr=0.0005)


scheduler = torch.optim.lr_scheduler.StepLR(optimizer, step_size=1, gamma=0.1)

device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")
model.to(device)
epochs = 1
step = 0
running_loss = 0
print_every = 1000
trainlossarr=[]
testlossarr=[]
oldacc=0

steps=math.ceil(len(train_data)/(trainloader.batch_size))

training = False

if training:
    for epoch in range(epochs):
        print(Style.RESET_ALL)
        print(f"--------------------------------- START OF EPOCH [ {epoch+1} ] >>> LR =  {optimizer.param_groups[-1]['lr']} ---------------------------------\n")
        for inputs, labels in tqdm(trainloader,desc=Fore.GREEN +f"* PROGRESS IN EPOCH {epoch+1} ",file=sys.stdout):
            model.train()
            step += 1
            inputs=inputs.to(device)
            labels=labels.to(device)

            optimizer.zero_grad()

            props = model.forward(inputs)
            loss = criterion(props, labels)
            loss.backward()
            optimizer.step()

            running_loss += loss.item()

            if (step % print_every == 0) or (step==steps):
                test_loss = 0
                accuracy = 0
                model.eval()
                with torch.no_grad():
                    for inputs, labels in testloader:
                        inputs, labels = inputs.to(device), labels.to(device)
                        props = model.forward(inputs)
                        batch_loss = criterion(props, labels)

                        test_loss += batch_loss.item()

                        ps = torch.exp(props)
                        top_p, top_class = ps.topk(1, dim=1)
                        equals = top_class == labels.view(*top_class.shape)
                        accuracy += torch.mean(equals.type(torch.FloatTensor)).item()
    
                        
                            

                tqdm.write(f"Epoch ({epoch+1} of {epochs}) ... "
                    f"Step  ({step:3d} of {steps}) ... "
                    f"Train loss: {running_loss/print_every:.3f} ... "
                    f"Test loss: {test_loss/len(testloader):.3f} ... "
                    f"Test accuracy: {accuracy/len(testloader):.3f} ")
                trainlossarr.append(running_loss/print_every)
                testlossarr.append(test_loss/len(testloader))
                running_loss = 0
                
            
        scheduler.step()
        step=0
    
    model_scripted = torch.jit.script(model) 
    model_scripted.save('test_model.pt')
    
if training:
    exit()
    
model = torch.jit.load('test_model.pt')
model.eval()

test_data = datasets.ImageFolder(valid_path,transforms.Compose([transforms.ToTensor()]))
testloader = torch.utils.data.DataLoader(test_data, batch_size=5000, shuffle=True)
images , labels=next( iter(testloader) )

accuracy = 0
for index in range(len(images)):
    test_img=images[index]

    t_n=transforms.Normalize([0.485, 0.456, 0.406],[0.229, 0.224, 0.225])
    test_img=t_n(test_img).unsqueeze(0).cuda()

    res = torch.exp(model(test_img))

    #invert class_to_idx keys to values and viceversa.
    classes=train_data.class_to_idx
    classes = {value:key for key, value in classes.items()}
    
    if classes[labels[index].item()] == classes[res.argmax().item()]:
        accuracy += 1
    
accuracy = accuracy/len(images)
print(accuracy)
    
