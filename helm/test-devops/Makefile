# Makefile for Test DevOps Helm Chart with Datadog Support

.PHONY: help build deploy deploy-datadog test logs status clean

NAMESPACE := test-devops
RELEASE := test-devops
CHART := ./helm/test-devops
DATADOG_API_KEY ?=

help: ## Show this help
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'

build: ## Build Docker image
	@echo "🔨 Building Docker image..."
	docker build -t test-devops:latest .
	@echo "✅ Image built successfully"

deploy: build ## Build and deploy WITHOUT Datadog (local testing)
	@echo "🚢 Deploying to Kubernetes (without Datadog)..."
	kubectl create namespace $(NAMESPACE) --dry-run=client -o yaml | kubectl apply -f -
	helm upgrade --install $(RELEASE) $(CHART) \
		--namespace $(NAMESPACE) \
		--set datadog.enabled=false \
		--wait \
		--timeout 2m
	@echo "✅ Deployment completed!"
	@echo ""
	@make status

deploy-datadog: build ## Build and deploy WITH Datadog
	@if [ -z "$(DATADOG_API_KEY)" ]; then \
		echo "❌ DATADOG_API_KEY is required"; \
		echo "Usage: make deploy-datadog DATADOG_API_KEY=your-api-key"; \
		exit 1; \
	fi
	@echo "🚢 Deploying to Kubernetes (with Datadog)..."
	kubectl create namespace $(NAMESPACE) --dry-run=client -o yaml | kubectl apply -f -
	helm upgrade --install $(RELEASE) $(CHART) \
		--namespace $(NAMESPACE) \
		--set datadog.enabled=true \
		--set datadog.apiKey=$(DATADOG_API_KEY) \
		--wait \
		--timeout 3m
	@echo "✅ Deployment completed with Datadog!"
	@echo ""
	@make status
	@make status-datadog

test: ## Test application endpoint
	@echo "🧪 Testing application..."
	@curl -s http://localhost:30080/ || echo "❌ Application not responding"
	@echo ""
	@curl -s http://localhost:30080/healthz || echo "❌ Health check failed"

logs: ## View application logs
	kubectl logs -n $(NAMESPACE) -l app.kubernetes.io/name=test-devops -f

logs-datadog: ## View Datadog Agent logs
	kubectl logs -n $(NAMESPACE) -l app=datadog-agent -f

status: ## Show deployment status
	@echo "📊 Application Status:"
	@kubectl get pods -n $(NAMESPACE) -l app.kubernetes.io/name=test-devops
	@echo ""
	@kubectl get svc -n $(NAMESPACE)
	@echo ""
	@echo "🌐 Access: http://localhost:30080"

status-datadog: ## Show Datadog Agent status
	@echo ""
	@echo "📊 Datadog Agent Status:"
	@kubectl get pods -n $(NAMESPACE) -l app=datadog-agent || echo "Datadog Agent not deployed"

check-datadog: ## Check Datadog Agent detailed status
	@POD=$$(kubectl get pods -n $(NAMESPACE) -l app=datadog-agent -o jsonpath='{.items[0].metadata.name}' 2>/dev/null); \
	if [ -z "$$POD" ]; then \
		echo "❌ Datadog Agent not found"; \
	else \
		echo "Checking Datadog Agent status..."; \
		kubectl exec -n $(NAMESPACE) $$POD -- agent status; \
	fi

restart: ## Restart deployment (after code changes)
	@echo "🔄 Restarting deployment..."
	@make build
	kubectl rollout restart deployment -n $(NAMESPACE)
	kubectl rollout status deployment -n $(NAMESPACE)
	@echo "✅ Restarted successfully"

clean: ## Remove deployment
	@echo "🗑️  Removing deployment..."
	helm uninstall $(RELEASE) -n $(NAMESPACE) || true
	kubectl delete namespace $(NAMESPACE) || true
	@echo "✅ Cleanup completed"

lint: ## Lint Helm chart
	helm lint $(CHART)

template: ## Show rendered templates
	helm template $(RELEASE) $(CHART)

template-datadog: ## Show rendered templates with Datadog
	helm template $(RELEASE) $(CHART) --set datadog.apiKey=test-key

