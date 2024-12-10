#import  needed libraries and check the used gpu
import torch
from torch import nn,optim
from torchvision import transforms, models ,datasets
import math
from tqdm import tqdm
from colorama import Fore,Style
import sys
import matplotlib.pyplot as plt
import numpy as np
import onnx

#print used Device
print(f"Device used: {torch.cuda.get_device_name(0)}")

#transforms
train_path='asl_alphabet_train'
valid_path='asl_alphabet_valid'
test_path='asl_alphabet_test'

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
validation_data = datasets.ImageFolder(valid_path, transform=test_transforms)

trainloader = torch.utils.data.DataLoader(train_data, batch_size=512, shuffle=True)
validationloader = torch.utils.data.DataLoader(validation_data, batch_size=512)

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

# define optimizer to train only the classifier and the previous three block.
parameters = [{'params':model.features[-1].parameters()},
                        {'params':model.features[-2].parameters()},
                        {'params':model.features[-3].parameters()},
                        {'params':model.classifier.parameters()}]

learning_rate = 0.0005
optimizer = optim.Adam(params=parameters, lr=learning_rate)

# define Learning Rate scheduler to decrease the learning rate by multiplying it by 0.1 after each epoch on the data.
scheduler = torch.optim.lr_scheduler.StepLR(optimizer, step_size=5, gamma=0.1)

device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")
model.to(device)
epochs = 40
step = 0
running_loss = 0
print_every = 500
trainlossarr=[]
vallossarr=[]
oldacc=0
max_unfreezing = 15

steps=math.ceil(len(train_data)/(trainloader.batch_size))

training = False

accs = []

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
                val_loss = 0
                accuracy = 0
                model.eval()
                with torch.no_grad():
                    for inputs, labels in validationloader:
                        inputs, labels = inputs.to(device), labels.to(device)
                        props = model.forward(inputs)
                        batch_loss = criterion(props, labels)

                        val_loss += batch_loss.item()

                        ps = torch.exp(props)
                        top_p, top_class = ps.topk(1, dim=1)
                        equals = top_class == labels.view(*top_class.shape)
                        accuracy += torch.mean(equals.type(torch.FloatTensor)).item()
    
                        
                            

                tqdm.write(f"Epoch ({epoch+1} of {epochs}) ... "
                    f"Step  ({step:3d} of {steps}) ... "
                    f"Train loss: {running_loss/print_every:.3f} ... "
                    f"Validation loss: {val_loss/len(validationloader):.3f} ... "
                    f"Validation accuracy: {accuracy/len(validationloader):.3f} ")
                trainlossarr.append(running_loss/print_every)
                vallossarr.append(val_loss/len(validationloader))
                accs.append(accuracy/len(validationloader))
                running_loss = 0
        
        num_params = len(parameters)    
        if num_params < max_unfreezing:   
            prev_layer = {'params':model.features[num_params * -1].parameters()}
            parameters.append(prev_layer)
            parameters[-1], parameters[-2] = parameters[-2], parameters[-1]
            optimizer = optim.Adam(params=parameters, lr=learning_rate)
        
        scheduler.step()
        step=0
        
    
    model_scripted = torch.jit.script(model) 
    model_scripted.save('test_model.pt')
    
if training:
    epochs_range = range(len(accs))
    plt.figure(figsize=(12, 8))

    # Accuracy plot
    plt.subplot(1, 2, 1)
    plt.plot(epochs_range, accs, label='Accuracy')
    plt.legend(loc='lower right')
    plt.title('Accuracy')

    # Loss plot
    plt.subplot(1, 2, 2)
    plt.plot(epochs_range, trainlossarr, label='Training Loss')
    plt.plot(epochs_range, vallossarr, label='Validation Loss')
    plt.legend(loc='upper right')
    plt.title('Training and Validation Loss')
    
    plt.show()
    exit()

model = torch.jit.load('test_model.pt')
model.to('cpu')
input_shape = (1, 3, 224, 224)

example_input = torch.randn(input_shape, requires_grad=True)
model(example_input)

input_names = ["input0"]
output_names = ["output0"]

dynamic_axes = {'input0': {0: 'batch'}, 'output0': {0: 'batch'}}

torch_out = torch.onnx.export(
    model, example_input, 'model.onnx', export_params=True, input_names=input_names, output_names=output_names, 
    dynamic_axes=dynamic_axes, operator_export_type=torch.onnx.OperatorExportTypes.ONNX
)

onnx_model = onnx.load("model.onnx")
onnx.checker.check_model(onnx_model)

model.to(device)
#turn model to evaluation mode
model.eval()

#load some of the test data 
test_data = datasets.ImageFolder(test_path,test_transforms)
testloader = torch.utils.data.DataLoader(test_data, batch_size=5000, shuffle=True)
images , labels=next( iter(testloader) )

accuracy = 0
for index in range(len(images)):
    test_img=images[index]

    #normalize image as in the training data
    test_img=test_img.unsqueeze(0).cuda()

    res = torch.exp(model(test_img))

    #invert class_to_idx keys to values and viceversa.
    classes=train_data.class_to_idx
    classes = {value:key for key, value in classes.items()}
    
    if classes[labels[index].item()] == classes[res.argmax().item()]:
        accuracy += 1
    
accuracy = accuracy/len(images)
print(accuracy)
    
