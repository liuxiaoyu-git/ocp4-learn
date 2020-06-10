oc new-project sample1
oc new-app httpd

oc new-project sample2
oc new-app httpd

sleep 2m

# From sample1 call sample2
oc exec -n sample1 $(oc get po -n sample1 -l deploymentconfig=httpd -o name) -- curl --max-time 2 http://httpd.sample2.svc.cluster.local:8080
# From sample1 call sample1
oc exec -n sample1 $(oc get po -n sample1 -l deploymentconfig=httpd -o name) -- curl --max-time 2 http://httpd.sample1.svc.cluster.local:8080

# From sample2 call sample1
oc exec -n sample2 $(oc get po -n sample2 -l deploymentconfig=httpd -o name) -- curl --max-time 2 http://httpd.sample1.svc.cluster.local:8080
# From sample2 call sample2
oc exec -n sample2 $(oc get po -n sample2 -l deploymentconfig=httpd -o name) -- curl --max-time 2 http://httpd.sample2.svc.cluster.local:8080

oc label namespace/openshift-ingress network.openshift.io/policy-group=ingress
oc label namespace/openshift-monitoring network.openshift.io/policy-group=monitoring

oc apply -f networkPolicy.yaml -n sample2

# From sample1 call sample2 -- It should fail
oc exec -n sample1 $(oc get po -n sample1 -l deploymentconfig=httpd -o name) -- curl --max-time 2 http://httpd.sample2.svc.cluster.local:8080
# From sample1 call sample1
oc exec -n sample1 $(oc get po -n sample1 -l deploymentconfig=httpd -o name) -- curl --max-time 2 http://httpd.sample1.svc.cluster.local:8080

# From sample2 call sample1
oc exec -n sample2 $(oc get po -n sample2 -l deploymentconfig=httpd -o name) -- curl --max-time 2 http://httpd.sample1.svc.cluster.local:8080
# From sample2 call sample2
oc exec -n sample2 $(oc get po -n sample2 -l deploymentconfig=httpd -o name) -- curl --max-time 2 http://httpd.sample2.svc.cluster.local:8080


# Now test from ingress as it should successes 
oc exec -n openshift-ingress $(oc get po -l ingresscontroller.operator.openshift.io/deployment-ingresscontroller=default --all-namespaces -o name |head -1) -- curl --max-time 2 http://httpd.sample2.svc.cluster.local:8080


