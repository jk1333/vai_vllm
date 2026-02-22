gcloud container clusters create vllm-cluster \
  --zone us-central1-a \
  --machine-type g2-standard-16 \
  --accelerator type=nvidia-l4,count=1,gpu-driver-version=LATEST \
  --num-nodes 1 \
  --network globalnetwork --subnetwork us-central1-private
  
cd ~
curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-x86_64.tar.gz
tar -xf google-cloud-cli-linux-x86_64.tar.gz
./google-cloud-sdk/install.sh --quiet
source ~/.bashrc
~/google-cloud-sdk/bin/gcloud components install gke-gcloud-auth-plugin --quiet
~/google-cloud-sdk/bin/gke-gcloud-auth-plugin --version
export USE_GKE_GCLOUD_AUTH_PLUGIN=True
~/google-cloud-sdk/bin/gcloud container clusters get-credentials vllm-cluster --zone us-central1-a
kubectl get nodes

kubectl apply -f vllm.yaml
kubectl apply -f prometheus.yaml
kubectl apply -f grafana.yaml

kubectl get svc grafana-service


http://<EXTERNAL-IP>:3000
http://prometheus-service:9090
grafana.json

kubectl port-forward svc/vllm-service 8000:8000

vllm bench serve \
  --backend openai \
  --base-url http://localhost:8000 \
  --model "mistralai/Mistral-7B-v0.1" \
  --dataset-name random \
  --random-input-len 256 \
  --random-output-len 128 \
  --num-prompts 1000 \
  --max-concurrency 32
  
  
python benchmark_serving.py --backend openai-chat --endpoint /v1/chat/completions --served-model-name=gpu --dataset-name=sonnet --dataset-path="./sonnet.txt" --model mistralai/Mistral-7B-v0.1  --base-url http://127.0.0.1:8000 --sonnet-input-len=2048 --sonnet-prefix-len=1024 --sonnet-output-len=1024 --seed=123 --max-concurrency=128